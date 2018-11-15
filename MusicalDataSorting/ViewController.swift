import Cocoa
import AVFoundation
typealias IndexAndBuffer = (index: Int, buffer: AVAudioPCMBuffer)

class ViewController: NSViewController {
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var uploadButton: NSButton!
	
	let audioEngine = AVAudioEngine()
	let audioPlayer = AVAudioPlayerNode()
	
	@IBAction func startMusicPrompt(_ sender: NSButton) {
		let fileSelectionPanel = NSOpenPanel()
		fileSelectionPanel.canChooseFiles = true
		fileSelectionPanel.allowsMultipleSelection = false
		fileSelectionPanel.canChooseDirectories = false
		
		fileSelectionPanel.beginSheetModal(for: view.window!) { result in
			guard result == .OK else { return }
			
			do {
				try playFile(at: fileSelectionPanel.urls[0], with: self.audioEngine, self.audioPlayer)
				self.statusLabel.stringValue = "Status - Successful"
			} catch {
				self.statusLabel.stringValue = "Status - Failed, try again"
				self.showAlert(for: error)
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		audioEngine.attach(audioPlayer)
		audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
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
