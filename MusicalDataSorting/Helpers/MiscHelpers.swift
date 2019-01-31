//
//  MiscHelpers.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

infix operator <-: NilCoalescingPrecedence

@discardableResult public func <- <T>(object: T, transform: (inout T) throws -> Void) rethrows -> T {
	var copy = object
	try transform(&copy)
	return copy
}

func showAlert(for error: Error) {
	print(error.localizedDescription)
	
	let description = """
	Your computer is about to blow up!
	
	\(error.localizedDescription)
	
	This is most likely due to the file not being an audio file or having no data.
	"""
	
	let newError = NSError(domain: "" , code: 0, userInfo: [NSLocalizedDescriptionKey: description])
	NSAlert(error: newError).runModal()
}
