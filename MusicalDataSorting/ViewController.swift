import Cocoa
import AVFoundation

class ViewController: NSViewController {
	let algorithmNames = ["Pick an Algorithm", "Bubble Sort", "Selection Sort"]
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
	var selectedAlgorithm: String!
	let minimumPieceCount = 10
	let maximumPieceCount = 25000
	let defaultPieceCount = 10
	var pieceCount = 0
	
	var audioFile: AudioFile!
	
	@IBAction func algorithmPopUpSelected(_ sender: NSPopUpButton) {
		let lastSelectedIndex = sender.indexOfSelectedItem
		let lastSelectedItem = sender.item(at: lastSelectedIndex)
		algorithmPopUpButton.setTitle(lastSelectedItem!.title)
		selectedAlgorithm = lastSelectedItem!.title
		sortButton.isEnabled = true
	}
	
	@IBAction func pieceCountEntered(_ sender: NSTextField) {
		var invalidInput = true
		
		if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: sender.stringValue)) {
			let numbers = Int(sender.stringValue)!
			if minimumPieceCount <= numbers && numbers <= maximumPieceCount {
				invalidInput = false
				
				pieceCountField.stringValue = String(numbers)
				pieceCount = numbers
				do {
					let audioFile = try AVAudioFile(forReading: filePath)
					let piecesSplit = try audioFile.splitIntoPieces(count: self.pieceCount)
					self.audioFile.pieces = piecesSplit.enumerated().map { MusicalAudioBuffer(with: $0.element, at: $0.offset, color: nil) }
					graphView.draw(graphView.frame)
				} catch {
					self.statusLabel.stringValue = "Status - Shuffling Failed"
					self.showAlert(for: error)
				}
			}
		}
		
		if invalidInput {
			pieceCountField.stringValue = String(defaultPieceCount)
		}
	}
	
	@IBAction func playFilePrompt(_ sender: Any) {
		do {
			self.graphView.draw(self.graphView.frame)
			if audioPlayer.isPlaying {
				audioPlayer.stop()
			}
			try playFile(with: audioPlayer, pieces: audioFile.pieces)
			self.statusLabel.stringValue = "Status - Played"
		} catch {
			self.statusLabel.stringValue = "Status - Playing Failed, try again"
			self.showAlert(for: error)
		}
	}
	
	@IBAction func shufflePrompt(_ sender: Any) {
		audioFile.pieces.shuffle()
		graphView.draw(graphView.frame)
		algorithmPopUpButton.isEnabled = true
	}
	
	@IBAction func sortFilePrompt(_ sender: Any) {
		algorithmPopUpButton.isEnabled = false
		pieceCountField.isEnabled = false
		shuffleButton.isEnabled = false
		sortButton.isEnabled = false
		uploadButton.isEnabled = false
		
		var sorter: SortingAlgorithm?
		
		switch selectedAlgorithm {
		case "Bubble Sort":
			sorter = BubbleSort(sorting: audioFile)
			
		case "Selection Sort":
			sorter = SelectionSort(sorting: audioFile)
			
		default:
			break;
		}
		
		guard sorter != nil else { return }
		let _ = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
			sorter!.step()
			self.graphView.needsDisplay = true
			
			if sorter!.isDone {
				timer.invalidate()
				self.pieceCountField.isEnabled = true
				self.shuffleButton.isEnabled = true
				self.uploadButton.isEnabled = true
			}
		}
	}
	
	@IBAction func startFileUploadPrompt(_ sender: NSButton) {
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
				self.audioFile.pieces = piecesSplit.enumerated().map { MusicalAudioBuffer(with: $0.element, at: $0.offset, color: nil) }
				self.pieceCountField.stringValue = String(self.defaultPieceCount)
				self.playButton.isEnabled = true
				self.pieceCountField.isEnabled = true
				self.shuffleButton.isEnabled = true
				self.graphView.needsDisplay = true
				self.sortButton.isEnabled = false
				self.algorithmPopUpButton.isEnabled = false
				
				self.statusLabel.stringValue = "Status - Uploaded"
				
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
	
	func prepareForUploading() {
		playButton.isEnabled = false
		algorithmPopUpButton.isEnabled = false
		algorithmPopUpButton.removeAllItems()
		algorithmPopUpButton.addItems(withTitles: algorithmNames)
		sortButton.isEnabled = false
		pieceCountField.isEnabled = false
		shuffleButton.isEnabled = false
		
		audioEngine.attach(audioPlayer)
		audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
		do {
			try audioEngine.start()
		} catch {
			statusLabel.stringValue = "Status - Failed to launch the audio engine"
			showAlert(for: error)
		}
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

struct PieceColors {
	var comparingTo: [Int] = []
	var comparingFrom: [Int] = []
}
