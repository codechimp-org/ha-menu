//
//  PrefsViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {


    @IBOutlet weak var textfieldServer: NSTextField!
    @IBOutlet weak var textfieldToken: NSTextField!

    var prefs = Preferences()

    override func viewDidLoad() {
        super.viewDidLoad()
        showExistingPrefs()
    }

    override func viewWillDisappear() {
        saveNewPrefs()
        super.viewWillDisappear()
    }

    func showExistingPrefs() {
        let server = prefs.server
        textfieldServer.stringValue = server

        let token = prefs.token
        textfieldToken.stringValue = token
    }

    func saveNewPrefs() {
        prefs.server = textfieldServer.stringValue
        prefs.token = textfieldToken.stringValue

        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }

}
