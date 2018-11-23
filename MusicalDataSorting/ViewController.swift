import Cocoa
import AVFoundation

class ViewController: NSViewController {
	let algorithmNames = ["Pick an Algorithm", "Bubble Sort", "Selection Sort", "This does nothing! Yeah!"]
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var uploadButton: NSButton!
	@IBOutlet weak var algorithmPopUpButton: NSPopUpButton!
	@IBOutlet weak var playButton: NSButton!
	@IBOutlet weak var sortButton: NSButton!
	@IBOutlet weak var splitCountField: NSTextField!
	@IBOutlet weak var shuffleButton: NSButton!
	
	var filePath: URL?
	let audioEngine = AVAudioEngine()
	let audioPlayer = AVAudioPlayerNode()
	
	
	@IBAction func algorithmPopUpSelected(_ sender: NSPopUpButton) {
		let lastSelectedIndex = sender.indexOfSelectedItem
		let lastSelectedItem = sender.item(at: lastSelectedIndex)
		algorithmPopUpButton.setTitle(lastSelectedItem!.title)
		sortButton.isEnabled = true
	}
	
	@IBAction func playFilePrompt(_ sender: Any) {
		do {
			guard self.filePath != nil else { return }
			if audioPlayer.isPlaying {
				audioPlayer.stop()
			}
			try playFile(at: filePath!, with: audioPlayer)
			self.statusLabel.stringValue = "Status - Played"
		} catch {
			self.statusLabel.stringValue = "Status - Playing Failed, try again"
			self.showAlert(for: error)
		}
	}
	
	@IBAction func shufflePrompt(_ sender: Any) {
		print("Prompted to shuffle")
		algorithmPopUpButton.isEnabled = true
	}
	
	@IBAction func splitNumberEntered(_ sender: Any) {
		print("Value for split count entered")
		shuffleButton.isEnabled = true
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
				let _ = try AVAudioFile(forReading: fileSelectionPanel.urls[0])
				self.filePath = fileSelectionPanel.urls[0]
				self.playButton.isEnabled = true
				self.splitCountField.isEnabled = true
				
				self.statusLabel.stringValue = "Status - Uploaded"
			} catch {
				self.statusLabel.stringValue = "Status - Upload Failed, try again"
				self.showAlert(for: error)
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		algorithmPopUpButton.removeAllItems()
		algorithmPopUpButton.addItems(withTitles: algorithmNames)
		
		audioEngine.attach(audioPlayer)
		audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
		do {
			try audioEngine.start()
		} catch {
			self.statusLabel.stringValue = "Status - Failed, try again"
			self.showAlert(for: error)
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
