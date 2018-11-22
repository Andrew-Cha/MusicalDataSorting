//
//  Timer.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation

class ParkBenchTimer {
	
	let startTime: CFAbsoluteTime
	var endTime: CFAbsoluteTime?
	
	init() {
		startTime = CFAbsoluteTimeGetCurrent()
	}
	
	func stop() -> CFAbsoluteTime {
		endTime = CFAbsoluteTimeGetCurrent()
		
		return duration!
	}
	
	var duration: CFAbsoluteTime? {
		if let endTime = endTime {
			return endTime - startTime
		} else {
			return nil
		}
	}
}
