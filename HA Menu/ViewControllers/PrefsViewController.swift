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
    @IBOutlet weak var textfieldGroup: NSTextField!
    @IBOutlet weak var buttonLogin: NSButton!

    var prefs = Preferences()

    override func viewDidLoad() {
        super.viewDidLoad()
        showExistingPrefs()
    }

    override func viewWillDisappear() {
        saveNewPrefs()
        NSApp.stopModal()
        super.viewWillDisappear()
    }

    func showExistingPrefs() {
        textfieldServer.stringValue = prefs.server
        textfieldToken.stringValue = prefs.token
        textfieldGroup.stringValue = prefs.groupList
        buttonLogin.state = (prefs.launch == true ? .on : .off)
    }

    func saveNewPrefs() {
        prefs.server = textfieldServer.stringValue
        prefs.token = textfieldToken.stringValue
        prefs.groupList = textfieldGroup.stringValue
        prefs.launch = (buttonLogin.state == .on)

        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }

}
