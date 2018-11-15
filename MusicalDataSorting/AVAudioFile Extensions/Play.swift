//
//  Play.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation
import AVFoundation

func playFile(at url: URL, with audioEngine: AVAudioEngine, _ audioPlayerNode: AVAudioPlayerNode) throws {
	do {
		let audioFile = try AVAudioFile(forReading: url)
		let pieces = try audioFile.splitIntoPieces(count: 4)
		let piecesEnumerated: [(index: Int, buffer: AVAudioPCMBuffer)] = pieces.enumerated().map { $0 }.shuffled()
		
		try audioEngine.start()
		Sorting.bubbleSort()
		for audioPiece in pieces.shuffled() {
			audioPlayerNode.scheduleBuffer(audioPiece)
		}
		
		audioPlayerNode.play()
	}
}
