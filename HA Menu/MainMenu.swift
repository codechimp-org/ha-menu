//
//  MainMenu.swift
//  HA Menu
//
//  Created by Andrew Jackson on 08/05/2022.
//

import Cocoa
import SwiftUI

final class MainMenu: NSObject, NSMenuDelegate {
    @Environment(\.openURL) private var openURL

    let menu = NSMenu()
    
    lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let menuItemAbout = 995
    
    override init() {
        super.init()
    }
    
    public func build() {
        statusItem.autosaveName = "org.codechimp.hamenu.menu"
        
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
        }
        
        buildStaticMenu()
        
        statusItem.menu = menu
        
        menu.delegate = self
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
    }
    
    public func menuDidClose(_ menu: NSMenu){
        
    }
    
    private func buildStaticMenu() {
        
        menu.addItem(NSMenuItem.separator())
        
        let prefMenu = NSMenuItem(title: "Preferences", action: #selector(openPreferences(sender:)), keyEquivalent: ",")
        prefMenu.target = self
        menu.addItem(prefMenu)
        
        menu.addItem(NSMenuItem.separator())
        
        //        let openHaMenu = NSMenuItem(title: "Open Home Assistant", action: #selector(openHA(sender:)), keyEquivalent: "")
        //        openHaMenu.target = self
        //        menu.addItem(openHaMenu)
        
        let openAbout = NSMenuItem(title: "About HA Menu", action: #selector(openAbout(sender:)), keyEquivalent: "")
        openAbout.tag = menuItemAbout
        openAbout.target = self
        menu.addItem(openAbout)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HA Menu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
    }
    
    @objc private func openPreferences(sender: NSMenuItem) {
        
        //        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //        if let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PrefsWindowController")) as? NSWindowController
        //        {
        //            NSApp.runModal(for: windowController.window!)
        //
        //            NSApp.activate(ignoringOtherApps: true)
        //        }
        
        openURL(URL(string: "haMenu://preferencesScene")!)
    }
    
    @objc func openAbout(sender: NSMenuItem) {
        let options = [String: Any]()
        NSApp.orderFrontStandardAboutPanel(options)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
