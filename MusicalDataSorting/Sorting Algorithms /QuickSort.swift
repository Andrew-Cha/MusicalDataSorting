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
	
	var stack = Stack<Int>()
	var leftIndex = 0
	var rightIndex: Int
	
	var pivotValue = 0
	var pivotIndex = 0
	
	var leftIndexOfSubset = 0
	var rightIndexOfSubset = 0
	
	var isDone = false
	
	init(sorting audioFile: AudioFile) {
		self.audioFile = audioFile
		
		leftIndex = pivotIndex + 1
		rightIndex = audioFile.pieces.count - 1
		
		stack.push(pivotIndex) //Stack Left To Right
		stack.push(audioFile.pieces.count - 1)
	}
	
	var isRecursionCompleted = false
	func step() {
		if stack.array.count > 0 || !isRecursionCompleted {
			if isRecursionCompleted {
				rightIndexOfSubset = stack.pop()! //Pop Right To Left
				leftIndexOfSubset = stack.pop()!
				
				leftIndex = leftIndexOfSubset + 1
				pivotIndex = leftIndexOfSubset
				rightIndex = rightIndexOfSubset
				
				pivotValue = audioFile.pieces[pivotIndex].index
				isRecursionCompleted = false
			}
			
			audioFile.pieces[pivotIndex].color = .yellow
			if leftIndex <= rightIndex { //while
				if leftIndex <= rightIndex && audioFile.pieces[leftIndex].index <= pivotValue {//while
					audioFile.pieces[leftIndex].color = .blue
					leftIndex += 1
				} else if leftIndex <= rightIndex && audioFile.pieces[rightIndex].index >= pivotValue {//while
					audioFile.pieces[rightIndex].color = .blue
					rightIndex -= 1
				} else if rightIndex >= leftIndex {
					audioFile.pieces[leftIndex].color = .red
					audioFile.pieces[rightIndex].color = .red
					audioFile.pieces.swapAt(leftIndex, rightIndex)
				}
			} else {
				if pivotIndex <= rightIndex {
					if audioFile.pieces[pivotIndex].index > audioFile.pieces[rightIndex].index {
						audioFile.pieces[pivotIndex].color = .red
						audioFile.pieces[rightIndex].color = .red
						audioFile.pieces.swapAt(pivotIndex, rightIndex)
					}
				}
				
				if leftIndexOfSubset < rightIndex {
					stack.push(leftIndexOfSubset) //Stack Left To Right
					stack.push(rightIndex - 1)
				}
				
				if rightIndexOfSubset > rightIndex {
					stack.push(rightIndex + 1) //Stack Left To Right
					stack.push(rightIndexOfSubset)
				}
				isRecursionCompleted = true
			}
		} else {
			isDone = true
		}
	}
}

struct Stack<Element> {
	fileprivate var array: [Element] = []
	
	mutating func push(_ element: Element) {
		array.append(element)
	}
	
	mutating func pop() -> Element? {
		return array.popLast()
	}
	
	func peek() -> Element? {
		return array.last
	}
}
