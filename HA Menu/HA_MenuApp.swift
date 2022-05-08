//
//  HA_MenuApp.swift
//  HA Menu
//
//  Created by Andrew Jackson on 08/05/2022.
//

import Cocoa
import SwiftUI

@main
struct HA_MenuApp: App {
    @Environment(\.scenePhase) var scenePhase
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: .zero)
        }
        
        //    Settings {
        //      EmptyView()
        //    }
        
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 300)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                                    hideButtons()
                                })
                .onAppear() {
                    // Disable the menu
                }
                .onDisappear() {
                    // Re-enable the menu
                }
        }
        .handlesExternalEvents(matching: ["preferencesScene"])
    }
    
    func hideButtons() {
        for window in NSApplication.shared.windows {
//            window.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = false
            window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isEnabled = false

        }
    }
}

// Our AppDelegate will handle our menu
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuExtrasConfigurator: MacExtrasConfigurator?
    
    final private class MacExtrasConfigurator: NSObject, NSMenuDelegate {
        @Environment(\.openURL) private var openURL

        private var statusBar: NSStatusBar
        private var statusItem: NSStatusItem
        
        let menuItemAbout = 995
        
        // MARK: - Lifecycle
        
        override init() {
            statusBar = NSStatusBar.system
            statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
            statusItem.autosaveName = "org.codechimp.hamenu.menu"
            
            super.init()
            
            createMenu()
        }
    
        
        // MARK: - MenuConfig
        
        private func createMenu() {
            
            if let statusButton = statusItem.button {
#if DEBUG
                let icon = NSImage(named: "StatusBarButtonImageDebug")
#else
                let icon = NSImage(named: "StatusBarButtonImage")
                icon?.isTemplate = true // best for dark mode
#endif
                
                statusButton.image = icon
                //            button.action = #selector(self.statusBarButtonClicked(sender:))
                statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
                
                let menu = NSMenu()
                
                menu.addItem(NSMenuItem.separator())
                
                let prefMenu = NSMenuItem(title: "Preferences", action: #selector(Self.openPreferences(_:)), keyEquivalent: ",")
                prefMenu.target = self
                menu.addItem(prefMenu)
                
                menu.addItem(NSMenuItem.separator())
                
                //        let openHaMenu = NSMenuItem(title: "Open Home Assistant", action: #selector(openHA(sender:)), keyEquivalent: "")
                //        openHaMenu.target = self
                //        menu.addItem(openHaMenu)
                
                let openAbout = NSMenuItem(title: "About HA Menu", action: #selector(Self.openAbout(_:)), keyEquivalent: "")
                openAbout.tag = menuItemAbout
                openAbout.target = self
                menu.addItem(openAbout)
                
                menu.addItem(NSMenuItem.separator())
                menu.addItem(NSMenuItem(title: "Quit HA Menu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
                
                statusItem.menu = menu
                
                menu.delegate = self
            }
        }
        
        public func menuWillOpen(_ menu: NSMenu){
            //        self.removeDynamicMenuItems()
            //
            //        self.addDynamicMenuItems(){
            //            result in
            //            switch result {
            //            case .success( _):
            //                self.checkForUpdate()
            //            case .failure( _):
            //                break
            //            }
            //        }
            print("Menu opened")
        }
        
        public func menuDidClose(_ menu: NSMenu){
            
        }
        
        // MARK: - Actions
        @objc private func openAbout(_ sender: Any?) {
            let options = [String: Any]()
            NSApp.orderFrontStandardAboutPanel(options)
            NSApp.activate(ignoringOtherApps: true)
        }
        
        @objc private func openPreferences(_ sender: Any?) {
            openURL(URL(string: "haMenu://preferencesScene")!)
        }
    }
    
    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        menuExtrasConfigurator = .init()
    }
}

