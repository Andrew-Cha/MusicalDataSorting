//
//  BubbleSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Cocoa

final class BubbleSort: SortingAlgorithm {
	var audioFile: AudioFile
	static var name = "Bubble Sort"
	
	var i = 0
	var j = 0
	var isDone = false
	
	init(sorting audioFile: AudioFile) {
		self.audioFile = audioFile
	}
	
	func step() {
		assert(!isDone)
		
		if audioFile.pieces[j].index > audioFile.pieces[j + 1].index {
			audioFile.pieces[j].color = NSColor.red
			audioFile.pieces[j + 1].color = NSColor.red
			audioFile.pieces.swapAt(j, j + 1)
		} else {
			audioFile.pieces[j].color = NSColor.green
		}
		
		j += 1
		if j >= audioFile.pieces.count - 1 - i {
			i += 1
			j = 0
			
			if i == audioFile.pieces.count {
				isDone = true
				audioFile.pieces[j].color = nil
			}
		}
	}
}
