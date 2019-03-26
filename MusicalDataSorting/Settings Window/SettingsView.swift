//
//  SettingsView.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/24/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

class SettingsView: NSView {
	@IBOutlet weak var delayField: NSTextField!
	var viewController: SettingsViewController!
	
	let defaultDelay = 0.125
	let minimumDelay = 0.001
	let maximumDelay = 2.0
	var currentDelay = 0.125 {
		didSet {
			delayField.stringValue = String(format: "%.3f", currentDelay)
			viewController.delegate?.sortingDelayChanged(to: currentDelay)
		}
	}
	
	@IBAction func abortButtonClicked(_ sender: Any) {
		viewController.delegate?.sortingAborted()
	}
	
	@IBAction func delayEntered(_ sender: NSTextField) {
		guard let uncheckedCount = Double(sender.stringValue) else {
			delayField.stringValue = String(defaultDelay)
			return
		}
		
		let count = Double.minimum(maximumDelay, .maximum(minimumDelay, uncheckedCount))
		currentDelay = count
	}
	
	@IBAction func sliderMoved(_ sender: NSSlider) {
		currentDelay = sender.doubleValue
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		delayField.stringValue = String(defaultDelay)
	}
}

protocol SettingsDelegate: AnyObject {
	func sortingAborted()
	func sortingDelayChanged(to newDelay: Double)
}
