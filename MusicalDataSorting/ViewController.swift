import Cocoa
import AVFoundation

class ViewController: NSViewController {
	let algorithmNames = ["Pick an Algorithm", "Bubble Sort", "Selection Sort", "This does nothing! Yeah!"]
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
	var pieces: [IndexAndBuffer]!
	var pieceCount = 100
	
	@IBAction func algorithmPopUpSelected(_ sender: NSPopUpButton) {
		let lastSelectedIndex = sender.indexOfSelectedItem
		let lastSelectedItem = sender.item(at: lastSelectedIndex)
		algorithmPopUpButton.setTitle(lastSelectedItem!.title)
		sortButton.isEnabled = true
	}
	
	@IBAction func pieceCountEntered(_ sender: NSTextField) {
		if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: sender.stringValue)) {
			let numbers = Int(sender.stringValue)!
			if 100 <= numbers && numbers <= 25000 {
				pieceCountField.stringValue = String(numbers)
				pieceCount = numbers
				do {
					let audioFile = try AVAudioFile(forReading: filePath)
					let piecesSplit = try audioFile.splitIntoPieces(count: self.pieceCount)
					self.pieces = piecesSplit.enumerated().map { $0 }
					graphView.draw(graphView.frame)
				} catch {
					self.statusLabel.stringValue = "Status - Shuffling Failed"
					self.showAlert(for: error)
				}
			} else {
				pieceCountField.stringValue = "100"
			}
		} else {
			pieceCountField.stringValue = "100"
		}
	}
	
	@IBAction func playFilePrompt(_ sender: Any) {
		do {
			self.graphView.draw(self.graphView.frame)
			if audioPlayer.isPlaying {
				audioPlayer.stop()
			}
			try playFile(with: audioPlayer, pieces: pieces)
			self.statusLabel.stringValue = "Status - Played"
		} catch {
			self.statusLabel.stringValue = "Status - Playing Failed, try again"
			self.showAlert(for: error)
		}
	}
	
	@IBAction func shufflePrompt(_ sender: Any) {
		pieces.shuffle()
		graphView.draw(graphView.frame)
		algorithmPopUpButton.isEnabled = true
	}
	
	@IBAction func sortFilePrompt(_ sender: Any) {
		print("Prompted to sort the file")
		sortButton.isEnabled = false
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
				let piecesSplit = try audioFile.splitIntoPieces(count: self.pieceCount)
				self.pieces = piecesSplit.enumerated().map { $0 }
				self.pieceCountField.stringValue = String(self.pieceCount)
				self.playButton.isEnabled = true
				self.pieceCountField.isEnabled = true
				self.shuffleButton.isEnabled = true
				self.graphView.draw(self.graphView.frame)
				
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
