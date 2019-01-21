//
//  MiscHelpers.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation

infix operator <-: NilCoalescingPrecedence

@discardableResult public func <- <T>(object: T, transform: (inout T) throws -> Void) rethrows -> T {
	var copy = object
	try transform(&copy)
	return copy
}
