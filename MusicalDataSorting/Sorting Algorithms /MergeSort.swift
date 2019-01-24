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
	static var name = "Merge Sort"
	
	/// 0 is our sorted array, while 1 is the one we copy from
	var currentDoubleBuffer = 0
	var doubleBuffer: [[MusicalAudioBuffer]]
	var pieceCount: Int
	var isDone = false
	
	var sortedFromLeft = 0
	
	var leftIndex = 0
	var leftWall = 0
	
	var rightIndex = 0
	var rightWall = 0
	
	//as our first pair is going to be of width 1
	var width = 1
	
	///	The difference between currentOffset and offset is that offset is used for determining whether we should increase the width
	/// once it hits the pieceCount, as that means the current pairs have been fully sorted.
	///	While currentOffset is used inside the merging of pairs to shift the current pair
	var offset = 0
	var currentOffset = 0
	
	var currentColor = NSColor.random
	var jumpedPair = true
	
	init(sorting audioFile: AudioFile) {
		self.audioFile = audioFile
		doubleBuffer = [audioFile.pieces, audioFile.pieces]
		pieceCount = audioFile.pieces.count
	}
	
	func transferData() {
		///	Another problem we run into is that we are always using one array for sorting (comparing values from) and one for writing onto.
		///	That means we can't really always pick one of them for drawing as it will have some elements out of date.
		///	Instead we store how many have been updated from the left and we draw the last X (sorted correctly) from the left
		
		// Sorted pieces
		for i in 0..<sortedFromLeft {
			audioFile.pieces[i] = doubleBuffer[1 - currentDoubleBuffer][i]
			// Unsorted pieces
			for j in sortedFromLeft..<pieceCount {
				audioFile.pieces[j] = doubleBuffer[currentDoubleBuffer][j]
			}
		}
	}
	
	func step() {
		assert(!isDone)
		
		///	If our width of a single left or right array does not exceed the total length of the pieces
		///	that means we can still sort, because there is still space for a left and right arrays
		///	For example [1, 2, 3, 4] [6, 7, 8, 9] if the width is 4 that means both arrays can still be
		///	used for sorting (4 < 8), although the next time they are combined, the width doubles and thus we can say
		///	that it is sorted, because [1, 2, 3, 4, 6, 7, 8, 9] ( 8 !< 8)
		
		if width < pieceCount {
			
			///	If our offset is valid, we can still jump through the left and right arrays, the offset is meant to be used to jump pairs
			//
			///	For example [1, 2] [3, 4] | [6, 7] [8, 9]
			///				Left   Right  | Left   Right
			///				First Pair	  |  Second Pair
			//
			///	Here the offset allows us to jump between these pairs, as long as it does not exceed the piece count it means we are still
			///	jumping pairs and thus it should continue
			
			if offset < pieceCount {
				
				///	An index here determines the current tracked place of either left or right arrays
				///
				///	For example in a default state: [1, 6, 7, 8, 9, 11, 12, 16] is our Left Array and [4, 5, 10, 13, 14] is our Right Array
				///									 ↑ Left Index			 ↑ Left Wall			   ↑ Right Index  ↑ Right Wall
				///
				/// We still have elements left in our left and right pairs, we can still merge them
				
				
				/// If we had jumped the pair last iteration
				if jumpedPair {
					currentColor = .random
					currentOffset = offset
					leftIndex = offset
					rightIndex = offset + width
					
					leftWall = min(leftIndex + width, pieceCount)
					rightWall = min(rightIndex + width, pieceCount)
					jumpedPair = false
				}
				
				//We still haven't hit the edge for both arrays
				if leftIndex < leftWall && rightIndex < rightWall {
					/// Is left pair lesser than right pair?
					if doubleBuffer[currentDoubleBuffer][leftIndex].index < doubleBuffer[currentDoubleBuffer][rightIndex].index {
						doubleBuffer[1 - currentDoubleBuffer][currentOffset] = doubleBuffer[currentDoubleBuffer][leftIndex]
						leftIndex += 1
						doubleBuffer[1 - currentDoubleBuffer][currentOffset].color = currentColor
					} else {
						doubleBuffer[1 - currentDoubleBuffer][currentOffset] = doubleBuffer[currentDoubleBuffer][rightIndex]
						rightIndex += 1
						doubleBuffer[1 - currentDoubleBuffer][currentOffset].color = currentColor
					}
					currentOffset += 1
				} else if leftIndex < leftWall { /// We still have elements in the left array
					doubleBuffer[1 - currentDoubleBuffer][currentOffset] = doubleBuffer[currentDoubleBuffer][leftIndex]
					doubleBuffer[1 - currentDoubleBuffer][currentOffset].color = currentColor
					currentOffset += 1
					leftIndex += 1
				} else if rightIndex < rightWall { /// We still have elements in the right array
					doubleBuffer[1 - currentDoubleBuffer][currentOffset] = doubleBuffer[currentDoubleBuffer][rightIndex]
					doubleBuffer[1 - currentDoubleBuffer][currentOffset].color = currentColor
					currentOffset += 1
					rightIndex += 1
				} else { /// We are done with the current pair otherwise, jump right!
					offset += width * 2
					jumpedPair = true
				}
				
				if !jumpedPair {
					sortedFromLeft += 1
				}
				
				transferData()
			} else {
				transferData()
				sortedFromLeft = 0
				
				/// If our current offset is greater than the piece count it means that
				/// we have jumped the pairs fully, thus fully merging a *Width* width size arrays
				
				/// Here we jump between the buffers we are writing to, since merge sort needs a copy of arrays we are always comparing from one and writing onto another
				currentDoubleBuffer = 1 - currentDoubleBuffer
				width *= 2
				offset = 0
			}
		} else {
			isDone = true
			audioFile.pieces = doubleBuffer[currentDoubleBuffer].map({ $0 <- { $0.color = nil } })
		}
	}
}


extension NSColor {
	static var random: NSColor {
		return NSColor(red: .random(in: 0...1.0), green: .random(in: 0...1.0), blue: .random(in: 0...1.0), alpha: 1.0)
	}
}
