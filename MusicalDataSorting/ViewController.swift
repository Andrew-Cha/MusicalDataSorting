import Cocoa
import AVFoundation

class ViewController: NSViewController {
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var uploadButton: NSButton!
	var filePath: URL?
	var audioPlayer: AVAudioPlayer!
	
	@IBAction func startMusicPrompt(_ sender: NSButton) {
		let fileSelectionPanel = NSOpenPanel()
		fileSelectionPanel.canChooseFiles = true
		fileSelectionPanel.allowsMultipleSelection = false
		fileSelectionPanel.canChooseDirectories = false
		
		fileSelectionPanel.beginSheetModal(for: view.window!) { result in
			guard result == .OK else { return }
			
			self.filePath = fileSelectionPanel.urls[0]
			
			do {
				guard let filePath = self.filePath else { return }
				let audioFile = try AVAudioFile(forReading: filePath)
				let splitAudioFile = try audioFile.splitIntoPieces(count: 2)
				
				let audioEngine = AVAudioEngine()
				let audioPlayer = AVAudioPlayerNode()
				let mainMixer = audioEngine.mainMixerNode
				let audioFormat = audioFile.processingFormat
				audioEngine.attach(audioPlayer)
				audioEngine.connect(audioPlayer, to: mainMixer, format: audioFormat)
				
				try audioEngine.start()
				
				for audioPiece in splitAudioFile {
					audioPlayer.scheduleBuffer(audioPiece)
					audioPlayer.play()
				}
				
				print(splitAudioFile.count)
				self.audioPlayer = try AVAudioPlayer(contentsOf: filePath)
				self.audioPlayer.prepareToPlay()
				self.audioPlayer.play()
				
				self.statusLabel.stringValue = "Status - Successful"
			} catch {
				self.statusLabel.stringValue = "Status - Failed, try again"
				print(error.localizedDescription)
				
				let description = """
				Your computer is about to blow up!
				
				\(error.localizedDescription)
				
				This is most likely due to the file not being an audio file.
				"""
				
				let newError = NSError(domain: "" , code: 0, userInfo: [NSLocalizedDescriptionKey: description])
				NSAlert(error: newError).runModal()
			}
		}
	}
	
	override func viewDidLoad() {
		// Do any additional setup after loading the view.
	}
}

extension AVAudioFile {
	func splitIntoPieces(count: Int) throws -> [AVAudioPCMBuffer] {
		let frameCount = Int(length)
		let splitFrameCount = frameCount / count + 1
		
		let sourceBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: .init(frameCount))!
		try read(into: sourceBuffer)
		let channelCount = Int(sourceBuffer.format.channelCount)
		
		return stride(from: 0, to: frameCount, by: splitFrameCount).map { startFrame -> AVAudioPCMBuffer in
			let splitBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: .init(splitFrameCount))!
			
			let sourceFrames = startFrame..<min(startFrame + splitFrameCount, frameCount)
			let targetFrames = stride(from: 0, to: splitFrameCount, by: sourceBuffer.stride)
			
			for channel in 0..<channelCount {
				for (sourceFrame, targetFrame) in zip(sourceFrames, targetFrames) {
					let sample = sourceBuffer.floatChannelData![channel][sourceFrame]
					splitBuffer.floatChannelData![channel][targetFrame] = sample
				}
			}
			
			return splitBuffer
		}
	}
}
