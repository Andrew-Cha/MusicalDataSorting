//
//  Bubble Sort.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation

protocol SortingAlgorithm {
	var audioFile: AudioFile { get set }
	var isDone: Bool { get set }
	
	init(sorting audioFile: AudioFile)
	
	func step()
}
