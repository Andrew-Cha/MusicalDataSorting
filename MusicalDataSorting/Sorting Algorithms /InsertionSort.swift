//
//  InsertionSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/17/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

final class InsertionSort: SortingAlgorithm {
	var audioFile: AudioFile
	
	var j = 1
	var i = 1
	var isDone = false
	
	init (sorting audioFile: AudioFile) {
		self.audioFile = audioFile
	}
	
	func step() {
		assert(!isDone)
		
		if audioFile.pieces[j - 1].index > audioFile.pieces[j].index {
			audioFile.pieces[j].color = NSColor.red
			audioFile.pieces[j - 1].color = NSColor.red
			audioFile.pieces.swapAt(j, j - 1)
		} else {
			audioFile.pieces[j - 1].color = NSColor.green
		}
		
		j -= 1
		if j <= 0 {
			i += 1
			j = i
			
			if i == audioFile.pieces.count {
				isDone = true
				audioFile.pieces[0].color = nil
			}
		}
	}
}
