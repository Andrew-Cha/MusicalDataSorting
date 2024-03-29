//
//  AudioFileInterfaces.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa
import AVFoundation

class AudioFile {
	//perhaps store the raw file here later?
	var viewController: MainViewController
	var pieces: [MusicalAudioBuffer]!
	
	init(in viewController: MainViewController) {
		self.viewController = viewController
	}
}

struct MusicalAudioBuffer {
	var buffer: AVAudioPCMBuffer
	var index: Int
	var color: NSColor?
	
	init(with buffer: AVAudioPCMBuffer, at index: Int) {
		self.buffer = buffer
		self.index = index
	}
}
