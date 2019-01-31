//
//  GraphView.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/22/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Cocoa

class GraphView: NSView {
	var viewController: MainViewController!
	
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
		
		for (index, audioFragment) in pieces.enumerated() {
			let coefficient = CGFloat(audioFragment.index + 1) / pieceCount
			let height = coefficient * frame.height
			let rect = NSRect(x: x, y: 0, width: width, height: height)
			
			if let color = audioFragment.color {
				if color != .black {
					context?.setFillColor(color.cgColor)
				}
				viewController.audioFile.pieces[index].color = nil
			}
			
			context?.fill(rect)
			context?.setFillColor(CGColor.black)
			
			x += width
		}
	}
}
