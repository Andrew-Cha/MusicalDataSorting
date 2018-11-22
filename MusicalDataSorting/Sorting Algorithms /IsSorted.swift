//
//  Sorted Check.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation

func isSorted(array: [IndexAndBuffer]) -> Bool {
	return zip(array, array.dropFirst()).map{ $0.index <= $1.index }.reduce(true) { $0 && $1 }
}
