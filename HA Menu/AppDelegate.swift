//
//  AppDelegate.swift
//  HA Menu
//
//  Created by Andrew Jackson on 21/10/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Cocoa
import ServiceManagement

let launcherAppId = "org.codechimp.HA-Menu-Launcher"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var menuItemController: MenuItemController?
    var prefs = Preferences()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupPrefs()

        // Kill the launcher Application
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty

        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }

        menuItemController = MenuItemController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
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
        print("Prefs Updated")

        SMLoginItemSetEnabled(launcherAppId as CFString, prefs.launch)

    }

}

