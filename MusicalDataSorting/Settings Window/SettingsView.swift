//
//  SettingsView.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/24/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

class SettingsView: NSView {
	
	override func awakeFromNib() {
		wantsLayer = true
		layer!.backgroundColor = NSColor.gray.cgColor
		
	}
}
