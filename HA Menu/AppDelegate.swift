//
//  AppDelegate.swift
//  HA Menu
//
//  Created by Andrew Jackson on 21/10/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var menuItemController: MenuItemController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menuItemController = MenuItemController()
    }

    var prefs = Preferences()


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


extension AppDelegate {
    // MARK: - Preferences
    func setupPrefs() {
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                                                self.updateFromPrefs()
        }
    }

    func updateFromPrefs() {
        // TODO: Reconnect
    }

}

