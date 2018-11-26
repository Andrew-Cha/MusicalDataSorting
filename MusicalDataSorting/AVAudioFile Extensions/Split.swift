//
//  PCMBuffer Split.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//
typealias IndexAndBuffer = (index: Int, buffer: AVAudioPCMBuffer)
import AVFoundation

extension AVAudioFile {
	func splitIntoPieces(count pieceCount: Int) throws -> [AVAudioPCMBuffer] {
		let frameCount = Int(length)
		let splitFrameCount = frameCount / pieceCount
		// Rounding down above technically makes us lose up to `pieceCount` frames, but it makes the logic much simpler and isn't really noticeable because typically there's _a lot_ more frames than pieces.
		
		let sourceBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: .init(frameCount))!
		try read(into: sourceBuffer)
		let channelCount = Int(sourceBuffer.format.channelCount)
		
		return stride(from: 0, to: splitFrameCount * pieceCount, by: splitFrameCount).map { startFrame -> AVAudioPCMBuffer in
			//splitFrameCount * pieceCount is used to match exactly how many pieces we will have, to not get an out of bounds error later at data writing
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
