//
//  Play.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import AVFoundation

func playFile(at url: URL, with audioPlayerNode: AVAudioPlayerNode) throws {
		let audioFile = try AVAudioFile(forReading: url)
		let pieces = try audioFile.splitIntoPieces(count: 10000)
		let piecesEnumerated: [(index: Int, buffer: AVAudioPCMBuffer)] = pieces.enumerated().map { $0 }
	
		for audioPiece in pieces {
			audioPlayerNode.scheduleBuffer(audioPiece)
		}
		
		audioPlayerNode.play()
}
