//
//  BubbleSort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation

final class BubbleSort: SortingAlgorithm {
	var array: [IndexAndBuffer]
	var colors: PieceColors
	
	var i = 0
	var j = 0
	var isDone = false
	
	init(sorting array: [IndexAndBuffer]) {
		self.array = array
		self.colors = PieceColors()
	}
	
	func step() {
		assert(!isDone)
		
		colors.comparingTo = []
		colors.comparingFrom = []
		
		if array[j].index > array[j + 1].index {
			array.swapAt(j, j + 1)
			colors.comparingFrom = [array[j].index, array[j + 1].index]
		} else {
			colors.comparingTo = [array[j].index]
		}
		
		j += 1
		if j >= array.count - 1 - i {
			i += 1
			j = 0
			
			if i == array.count {
				isDone = true
				colors = PieceColors()
			}
		}
	}
}
