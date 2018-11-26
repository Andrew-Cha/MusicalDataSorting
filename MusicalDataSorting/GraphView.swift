//
//  GraphView.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Cocoa

class GraphView: NSView {
	var viewController: ViewController?
	
	override func awakeFromNib() {
		self.wantsLayer = true
		self.layer!.backgroundColor = NSColor.gray.cgColor
		self.layer!.cornerRadius = 10
	}
	
	override func draw(_ dirtyRect: NSRect) {
		
	}
}
