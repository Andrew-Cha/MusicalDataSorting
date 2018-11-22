//
//  GraphView.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Foundation
import Cocoa

class GraphView: NSView {
	override func awakeFromNib() {
		self.wantsLayer = true
		self.layer?.backgroundColor = NSColor.gray.cgColor
		self.layer?.cornerRadius = 10
	}
}
