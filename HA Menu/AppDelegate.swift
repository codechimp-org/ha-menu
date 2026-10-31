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

@main
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

        UserDefaults.standard.register(defaults: [
               "domain_lights": true,
               "domain_switches": true,
               "domain_automations": true,
               "domain_inputbooleans": true,
               "domain_inputselects": true,
               "domain_scenes": true,
               "domain_scripts": true,
               "domain_covers": true,
               "domain_buttons": true,
               "domain_inputbuttons": true,
               "betaNotifications": false
               ])

        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                                                self.updateFromPrefs()
        }
    }

    func updateFromPrefs() {
        if #available(macOS 13.0, *) {
            do {
                if prefs.launch {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // SMAppService can throw (e.g. requiresApproval when the user
                // must enable the app in System Settings > General > Login Items).
                // Never crash the host app for a login-item failure.
                print("SMAppService error: \(error)")
            }
        } else {
            // macOS 11.5 - 12 fallback for the pre-13 login-item API.
            SMLoginItemSetEnabled(launcherAppId as CFString, prefs.launch)
        }
    }

}

