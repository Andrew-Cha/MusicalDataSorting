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
	var i = 0
	var minIndex = 0
	var j = 1
	var isDone = false
	
	init(sorting array: [IndexAndBuffer]) {
		self.array = array
	}
	
	func step() {
		assert(!isDone)
		
		if array[j].index < array[minIndex].index {
			minIndex = j
		}
		
		if j >= array.count - 1 {
			array.swapAt(i, minIndex)
			i += 1
			minIndex = i
			j = i + 1
			
			if j == array.count {
				isDone = true
			}
		} else {
			j += 1
		}
		
	}
}
