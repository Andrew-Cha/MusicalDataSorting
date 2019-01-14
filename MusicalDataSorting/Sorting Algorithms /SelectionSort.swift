//
//  SelectionSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation

final class SelectionSort: SortingAlgorithm {
	var array: [IndexAndBuffer]
	var colors: PieceColors
	
	var i = 0
	var minIndex = 0
	var j = 1
	var isDone = false
	
	init(sorting array: [IndexAndBuffer]) {
		self.array = array
		self.colors = PieceColors()
	}
	
	func step() {
		assert(!isDone)
		
		colors.comparingTo = []
		colors.comparingFrom = []
		
		if array[j].index < array[minIndex].index {
			colors.comparingFrom = [array[j].index, array[minIndex].index]
			minIndex = j
		} else {
			colors.comparingTo = [array[j].index]
		}
		
		if j >= array.count - 1 {
			array.swapAt(i, minIndex)
			i += 1
			minIndex = i
			j = i + 1
			
			if j == array.count {
				isDone = true
				colors = PieceColors()
			}
		} else {
			j += 1
		}
		
	}
}
