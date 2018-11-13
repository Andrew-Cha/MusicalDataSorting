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
		let frameCount = AVAudioFrameCount(length)
		let splitAudioBufferLength = Int(frameCount) / count + 1
		
		let baseBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCount)!
		
		try read(into: baseBuffer)
		
		let channelCount = Int(baseBuffer.format.channelCount)
		
		var currentFrame = 0
		var splitAudioBuffers: [AVAudioPCMBuffer] = []
		var currentSplitAudioBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(splitAudioBufferLength))!
		for baseFrame in 0 ..< Int(baseBuffer.frameLength) {
			for channelNumber in 0 ..< channelCount {
				let sample = baseBuffer.floatChannelData![channelNumber][baseFrame]
				currentSplitAudioBuffer.floatChannelData![channelNumber][currentFrame] = sample
			}
			
			currentFrame += 1
			if currentFrame == splitAudioBufferLength {
				currentFrame = 0
				splitAudioBuffers.append(currentSplitAudioBuffer)
				currentSplitAudioBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(splitAudioBufferLength))!
			}
		}
		
		return splitAudioBuffers
	}
}
