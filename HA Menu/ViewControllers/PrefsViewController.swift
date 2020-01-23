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
    @IBOutlet weak var buttonLights: NSButton!
    @IBOutlet weak var buttonSwitches: NSButton!
    @IBOutlet weak var buttonAutomations: NSButton!
    @IBOutlet weak var buttonInputBooleans: NSButton!
    @IBOutlet weak var buttonInputSelects: NSButton!

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
        buttonLights.state = (prefs.domainLights == true ? .on : .off)
        buttonSwitches.state = (prefs.domainSwitches == true ? .on : .off)
        buttonAutomations.state = (prefs.domainAutomations == true ? .on : .off)
        buttonInputBooleans.state = (prefs.domainInputBooleans == true ? .on : .off)
        buttonInputSelects.state = (prefs.domainInputSelects == true ? .on : .off)
        textfieldGroup.stringValue = prefs.groupList
        buttonLogin.state = (prefs.launch == true ? .on : .off)
    }

    func saveNewPrefs() {
        prefs.server = textfieldServer.stringValue
        prefs.token = textfieldToken.stringValue
        prefs.domainLights = (buttonLights.state == .on)
        prefs.domainSwitches = (buttonSwitches.state == .on)
        prefs.domainAutomations = (buttonAutomations.state == .on)
        prefs.domainInputBooleans = (buttonInputBooleans.state == .on)
        prefs.domainInputSelects = (buttonInputSelects.state == .on)
        prefs.groupList = textfieldGroup.stringValue
        prefs.launch = (buttonLogin.state == .on)

        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }

}
