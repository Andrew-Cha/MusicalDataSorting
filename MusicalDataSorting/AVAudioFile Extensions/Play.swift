//
//  Play.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import AVFoundation

func playFile(with audioPlayerNode: AVAudioPlayerNode, pieces: [IndexAndBuffer]) throws {
	for (_, audioPiece) in pieces {
			audioPlayerNode.scheduleBuffer(audioPiece)
		}
		
		audioPlayerNode.play()
}
