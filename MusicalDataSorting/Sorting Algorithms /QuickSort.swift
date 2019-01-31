//
//  QuickSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

final class QuickSort: SortingAlgorithm {
	var audioFile: AudioFile
	
	var isDone = false
	
	init(sorting audioFile: AudioFile) {
		self.audioFile = audioFile
	}
	
	//remember how deep the splits are, once a whole recursion is done come back?
	// display the splits and how each side is sorted, remember the widths and where the current recursion is at, display pivot?
	func step() {
		if true {
			isDone = true
		}
	}
	
}

