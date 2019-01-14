//
//  GraphView.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Cocoa

class GraphView: NSView {
	var viewController: ViewController!
	
	override func awakeFromNib() {
		self.wantsLayer = true
		self.layer!.backgroundColor = NSColor.gray.cgColor
		self.layer!.cornerRadius = 10
		super.awakeFromNib()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		guard let pieces = viewController?.pieces else { return }
		let colors = viewController?.colors
		
		super.draw(dirtyRect)
		let context = NSGraphicsContext.current?.cgContext
		
		let pieceCount = CGFloat(pieces.count)
		let width = frame.width / pieceCount
		var x: CGFloat = 0
		
		for (index, _) in pieces {
			let coefficient = CGFloat(index + 1) / pieceCount
			let height = coefficient * frame.height
			let rect = NSRect(x: x, y: 0, width: width, height: height)
			
			if let comparingFrom = colors?.comparingFrom {
				if comparingFrom.contains(index) {
					NSColor.red.setFill()
				}
			}
			
			if let comparingTo = colors?.comparingTo {
				if comparingTo.contains(index) {
					NSColor.green.setFill()
				}
			}
			context?.fill(rect)
			
			NSColor.black.setFill()
			x += width
		}
	}
}
