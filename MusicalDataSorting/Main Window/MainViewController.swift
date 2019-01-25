import Cocoa
import AVFoundation

class MainViewController: NSViewController, SettingsDelegate {
	let sortingAlgorithms: [String: SortingAlgorithm.Type] = ["Bubble Sort": BubbleSort.self,
															  "Merge Sort": MergeSort.self,
															  "Insertion Sort": InsertionSort.self,
															  "Selection Sort": SelectionSort.self]
	
	@IBOutlet weak var graphView: GraphView!
	
	@IBOutlet weak var algorithmPopUpButton: NSPopUpButton!
	@IBOutlet weak var playButton: NSButton!
	@IBOutlet weak var sortButton: NSButton!
	@IBOutlet weak var shuffleButton: NSButton!
	@IBOutlet weak var uploadButton: NSButton!
	
	@IBOutlet weak var pieceCountField: NSTextField!
	@IBOutlet weak var statusLabel: NSTextField!
	
	let audioEngine = AVAudioEngine()
	let audioPlayer = AVAudioPlayerNode()
	
	var filePath: URL!
	var isSortingPaused = false
	var selectedAlgorithm: String!
	
	var currentDelay = 0.125
	
	let defaultPieceCount = 100
	let minimumPieceCount = 8
	let maximumPieceCount = 25000
	var pieceCount = 0 {
		didSet { pieceCountField.stringValue = String(pieceCount) }
	}
	
	var audioFile: AudioFile!
	
	@IBAction func algorithmPopUpSelected(_ sender: NSPopUpButton) {
		let lastSelectedIndex = sender.indexOfSelectedItem
		let lastSelectedItem = sender.item(at: lastSelectedIndex)
		algorithmPopUpButton.setTitle(lastSelectedItem!.title)
		selectedAlgorithm = lastSelectedItem!.title
		sortButton.isEnabled = true
	}
	
	@IBAction func pieceCountEntered(_ sender: NSTextField) {
		guard let uncheckedCount = Int(sender.stringValue) else {
			pieceCountField.stringValue = String(defaultPieceCount)
			return
		}
		
		let count = min(maximumPieceCount, max(minimumPieceCount, uncheckedCount))
		pieceCount = count
		
		do {
			let audioFile = try AVAudioFile(forReading: filePath)
			let piecesSplit = try audioFile.splitIntoPieces(count: pieceCount)
			self.audioFile.pieces = piecesSplit.enumerated().map { MusicalAudioBuffer(with: $0.element, at: $0.offset) }
			graphView.draw(graphView.frame)
		} catch {
			statusLabel.stringValue = "Status - Shuffling Failed"
			showAlert(for: error)
		}
	}
	
	@IBAction func playFilePrompt(_ sender: NSButton) {
		do {
			graphView.draw(graphView.frame)
			if audioPlayer.isPlaying {
				audioPlayer.stop()
			}
			try playFile(with: audioPlayer, pieces: audioFile.pieces)
			statusLabel.stringValue = "Status - Played"
		} catch {
			statusLabel.stringValue = "Status - Playing Failed, try again"
			showAlert(for: error)
		}
	}
	
	@IBAction func shufflePrompt(_ sender: NSButton) {
		audioFile.pieces.shuffle()
		graphView.draw(graphView.frame)
		algorithmPopUpButton.isEnabled = true
	}
	
	@IBAction func sortFilePrompt(_ sender: NSButton) {
		if sender.title == "Sort" {
			prepareForSortingStart()
			
			var sorter: SortingAlgorithm?
			if let sortingAlgorithm = sortingAlgorithms[selectedAlgorithm] {
				sorter = sortingAlgorithm.init(sorting: audioFile)
			}
			
			guard sorter != nil else { prepareForSortingEnd(); return }
			let _ = Timer.scheduledTimer(withTimeInterval: currentDelay, repeats: true) { timer in
				if !self.isSortingPaused {
					sorter!.step()
					self.graphView.needsDisplay = true
					
					if sorter!.isDone {
						timer.invalidate()
						self.prepareForSortingEnd()
					}
				}
			}
		} else if sender.title == "Pause" {
			isSortingPaused = true
			sortButton.title = "Unpause"
		} else if sender.title == "Unpause" {
			isSortingPaused = false
			sortButton.title = "Pause"
		}
	}
	
	@IBAction func uploadFilePrompt(_ sender: NSButton) {
		let fileSelectionPanel = NSOpenPanel()
		fileSelectionPanel.canChooseFiles = true
		fileSelectionPanel.allowsMultipleSelection = false
		fileSelectionPanel.canChooseDirectories = false
		
		fileSelectionPanel.beginSheetModal(for: view.window!) { result in
			guard result == .OK else { return }
			
			do {
				self.filePath = fileSelectionPanel.urls[0]
				
				let audioFile = try AVAudioFile(forReading: self.filePath)
				let piecesSplit = try audioFile.splitIntoPieces(count: self.defaultPieceCount)
				
				self.audioFile.pieces = piecesSplit.enumerated().map { MusicalAudioBuffer(with: $0.element, at: $0.offset) }
				self.pieceCountField.stringValue = String(self.defaultPieceCount)
				self.statusLabel.stringValue = "Status - Uploaded"
				
				self.prepareForShuffling()
			} catch {
				self.statusLabel.stringValue = "Status - Upload Failed, try again"
				self.showAlert(for: error)
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.graphView.viewController = self
		self.audioFile = AudioFile(in: self)
		prepareForUploading()
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if let destination = segue.destinationController as? SettingsViewController {
			destination.delegate = self
		}
	}
	
	func prepareForShuffling() {
		algorithmPopUpButton.isEnabled = false
		graphView.needsDisplay = true
		pieceCountField.isEnabled = true
		playButton.isEnabled = true
		shuffleButton.isEnabled = true
		sortButton.isEnabled = false
	}
	
	func prepareForSortingEnd() {
		pieceCountField.isEnabled = true
		sortButton.isEnabled = false
		sortButton.title = "Sort"
		shuffleButton.isEnabled = true
		uploadButton.isEnabled = true
	}
	
	func prepareForSortingStart() {
		algorithmPopUpButton.isEnabled = false
		pieceCountField.isEnabled = false
		shuffleButton.isEnabled = false
		sortButton.title = "Pause"
		uploadButton.isEnabled = false
	}
	
	func prepareForUploading() {
		algorithmPopUpButton.isEnabled = false
		algorithmPopUpButton.removeAllItems()
		var algorithmNames: [String] = []
		algorithmNames.append(contentsOf: sortingAlgorithms.keys.map({ $0 }).sorted())
		algorithmNames.insert("Pick An Algorithm", at: 0)
		algorithmPopUpButton.addItems(withTitles: algorithmNames)
		
		playButton.isEnabled = false
		pieceCountField.isEnabled = false
		shuffleButton.isEnabled = false
		sortButton.isEnabled = false
		
		audioEngine.attach(audioPlayer)
		audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
		do {
			try audioEngine.start()
		} catch {
			statusLabel.stringValue = "Status - Failed to launch the audio engine"
			showAlert(for: error)
		}
	}
	
	func sortingDelayChanged(to newDelay: Double) {
		currentDelay = newDelay
	}
	
	func showAlert(for error: Error) {
		print(error.localizedDescription)
		
		let description = """
		Your computer is about to blow up!
		
		\(error.localizedDescription)
		
		This is most likely due to the file not being an audio file or having no data.
		"""
		
		let newError = NSError(domain: "" , code: 0, userInfo: [NSLocalizedDescriptionKey: description])
		NSAlert(error: newError).runModal()
	}
}
