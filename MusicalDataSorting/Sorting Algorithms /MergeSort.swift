//
//  MergeSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/18/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

final class MergeSort: SortingAlgorithm {
	var audioFile: AudioFile
	var midpoint: Int
	
	//left side index
	var l = 0
	var leftIsSplit = false
	var leftIsSorted = false
	var leftIsOdd = false
	
	//right side index
	var r: Int
	var rightIsSplit = false
	var rightIsSorted = false
	var rightIsOdd = false
	
	var isDone = false
	
	init(sorting audioFile: AudioFile) {
		self.audioFile = audioFile
		self.midpoint = audioFile.pieces.count / 2
		self.r = midpoint
	}
	
	func step() {
		assert(!isDone)
		
		if !leftIsSorted { //Check if left side is good
			if !leftIsSplit { //Check if we've done the recursive sorting
				if l + 1 < midpoint { //if we haven't split up to the midpoint, as in the recursion for the left side is not done
					if audioFile.pieces[l].index > audioFile.pieces[l + 1].index {
						audioFile.pieces.swapAt(l, l + 1)
						audioFile.pieces[l].color = NSColor.red
						audioFile.pieces[l + 1].color = NSColor.red
					} else {
						audioFile.pieces[l].color = NSColor.green
						audioFile.pieces[l + 1].color = NSColor.green
					}
					l += 2
				} else { //otherwise check perhaps there is a pair with only 1 member in it
					if midpoint % 2 != 0 { //if it's the lonely single man left
						audioFile.pieces[l].color = NSColor.green //then color it green
						leftIsOdd = true
					}
					leftIsSplit = true
					l = 0
				}
			} else { //once we do the splitting, do the recursive merging
				leftIsSorted = true //placeholder
			}
		} else if !rightIsSorted {
			if !rightIsSplit {
				if r + 1 < audioFile.pieces.count {
					if audioFile.pieces[r].index > audioFile.pieces[r + 1].index {
						audioFile.pieces.swapAt(r, r + 1)
						audioFile.pieces[r].color = NSColor.red
						audioFile.pieces[r + 1].color = NSColor.red
					} else {
						audioFile.pieces[r].color = NSColor.green
						audioFile.pieces[r + 1].color = NSColor.green
					}
					
					r += 2
				} else {
					if audioFile.pieces.count - midpoint % 2 != 0 {
						audioFile.pieces[r].color = NSColor.green
						rightIsOdd = true
					}
					rightIsSplit = true
					r = midpoint
				}
			} else {
				rightIsSorted = true //placeholder
			}
		} else {
			if leftIsSorted && rightIsSorted {
				//merge both
				isDone = true
			}
		}
	}
	
}
