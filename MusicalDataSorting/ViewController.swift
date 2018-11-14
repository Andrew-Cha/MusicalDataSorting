import Cocoa
import AVFoundation

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
			
			self.playFile(at: fileSelectionPanel.urls[0])
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		audioEngine.attach(audioPlayer)
		audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
	}
	
	func playFile(at url: URL) {
		do {
			let audioFile = try AVAudioFile(forReading: url)
			let pieces = try audioFile.splitIntoPieces(count: 8)
			
			try audioEngine.start()
			
			for audioPiece in pieces {
				audioPlayer.scheduleBuffer(audioPiece)
			}
			
			audioPlayer.play()
			
			statusLabel.stringValue = "Status - Successful"
		} catch {
			statusLabel.stringValue = "Status - Failed, try again"
			showAlert(for: error)
		}
	}
	
	func showAlert(for error: Error) {
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

extension AVAudioFile {
	func splitIntoPieces(count pieceCount: Int) throws -> [AVAudioPCMBuffer] {
		let frameCount = Int(length)
		let splitFrameCount = frameCount / pieceCount
		// Rounding down above technically makes us lose up to `pieceCount` frames, but it makes the logic much simpler and isn't really noticeable because typically there's _a lot_ more frames than pieces.
		
		let sourceBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: .init(frameCount))!
		try read(into: sourceBuffer)
		let channelCount = Int(sourceBuffer.format.channelCount)
		
		return stride(from: 0, to: frameCount, by: splitFrameCount).map { startFrame -> AVAudioPCMBuffer in
			let splitBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: .init(splitFrameCount))!
			splitBuffer.frameLength = .init(splitFrameCount)
			
			if sourceBuffer.format.isInterleaved { // interleaved format
				let sourceData = sourceBuffer.floatChannelData![0]
				let targetData = splitBuffer.floatChannelData![0]
				targetData.initialize(from: sourceData.advanced(by: startFrame * channelCount), count: splitFrameCount * channelCount)
			} else { // have to copy each channel separately
				for channel in 0..<channelCount {
					let sourceData = sourceBuffer.floatChannelData![channel]
					let targetData = splitBuffer.floatChannelData![channel]
					targetData.initialize(from: sourceData.advanced(by: startFrame), count: splitFrameCount)
				}
			}
			
			return splitBuffer
		}
	}
}
