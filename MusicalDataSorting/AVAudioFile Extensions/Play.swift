//
//  Play.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import AVFoundation

func playFile(with audioPlayerNode: AVAudioPlayerNode, pieces: [MusicalAudioBuffer]) throws {
	for audioFragment in pieces {
			audioPlayerNode.scheduleBuffer(audioFragment.buffer)
		}
		
		audioPlayerNode.play()
}
