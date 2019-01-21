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
		wantsLayer = true
		layer!.backgroundColor = NSColor.gray.cgColor
		layer!.cornerRadius = 10
		super.awakeFromNib()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		guard let pieces = viewController?.audioFile.pieces else { return }
		
		super.draw(dirtyRect)
		let context = NSGraphicsContext.current?.cgContext
		
		let pieceCount = CGFloat(pieces.count)
		let width = frame.width / pieceCount
		var x: CGFloat = 0
		
		for (index, audioFragment) in viewController.audioFile.pieces.enumerated() {
			let coefficient = CGFloat(audioFragment.index + 1) / pieceCount
			let height = coefficient * frame.height
			let rect = NSRect(x: x, y: 0, width: width, height: height)
			
			if let color = audioFragment.color {
				if color == NSColor.red {
					context?.setFillColor(CGColor.init(red: 255, green: 0, blue: 0, alpha: 255))
				} else if color == NSColor.green {
					context?.setFillColor(CGColor.init(red: 0, green: 255, blue: 0, alpha: 255))
				}
				context?.fill(rect)
				context?.setFillColor(CGColor.black)
		
				viewController.audioFile.pieces[index].color = nil
			} else {
				context?.fill(rect)
			}
			
			x += width
		}
	}
}
