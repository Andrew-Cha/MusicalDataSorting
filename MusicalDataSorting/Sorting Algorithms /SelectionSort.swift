//
//  SelectionSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Cocoa

final class SelectionSort: SortingAlgorithm {
	var audioFile: AudioFile
	static var name = "Selection Sort"
	
	var i = 0
	var minIndex = 0
	var j = 1
	var isDone = false
	
	init(sorting audioFile: AudioFile) {
		self.audioFile = audioFile
	}
	
	func step() {
		assert(!isDone)
		
		if audioFile.pieces[j].index < audioFile.pieces[minIndex].index {
			audioFile.pieces[j].color = NSColor.red
			audioFile.pieces[minIndex].color = NSColor.red
			minIndex = j
		} else {
			audioFile.pieces[j].color = NSColor.green
		}
		
		if j >= audioFile.pieces.count - 1 {
			audioFile.pieces.swapAt(i, minIndex)
			i += 1
			minIndex = i
			j = i + 1
			
			if j == audioFile.pieces.count {
				isDone = true
				audioFile.pieces[i].color = nil
				audioFile.pieces[i - 1].color = nil
			}
		} else {
			j += 1
		}
		
	}
}
