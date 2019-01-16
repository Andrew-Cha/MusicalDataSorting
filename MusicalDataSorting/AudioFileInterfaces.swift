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
	var viewController: ViewController
	var pieces: [MusicalAudioBuffer]! {
		didSet { viewController.graphView.setNeedsDisplay(viewController.graphView.bounds) }
	}
	
	init(in viewController: ViewController) {
		self.viewController = viewController
	}
}

struct MusicalAudioBuffer {
	var buffer: AVAudioPCMBuffer
	var index: Int
	var color: NSColor?
	
	init(with buffer: AVAudioPCMBuffer, at index: Int, color: NSColor?) {
		self.buffer = buffer
		self.index = index
		self.color = color
	}
}
