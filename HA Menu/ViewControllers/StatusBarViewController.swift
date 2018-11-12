//
//  StatusBarViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Cocoa

class StatusBarViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension StatusBarViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> StatusBarViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("StatusBarViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? StatusBarViewController else {
            fatalError("Why cant i find StatusBarViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
