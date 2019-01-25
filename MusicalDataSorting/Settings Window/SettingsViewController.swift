//
//  SettingsViewController.swift
//  MusicalDataSorting
//
//  Created by Andrew on 1/24/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	@IBOutlet var settingsView: SettingsView!
	weak var delegate: SettingsDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		settingsView.viewController = self
	}
	
	override func viewDidAppear() {
		settingsView.window!.styleMask.remove(.resizable)
	}
}
