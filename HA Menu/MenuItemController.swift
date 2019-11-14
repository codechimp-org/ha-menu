//
//  MenuItemController
//  HA Menu
//
//  Created by Andrew Jackson on 07/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation
import Cocoa

final class MenuItemController: NSObject, NSMenuDelegate {
    
    var prefs = Preferences()
    var haStates : [HaState]?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    
    var preferences: Preferences

    enum menuItemTypes: Int {
        case switchType = 2
        case scriptType = 3
        case inputbooleanType = 4
    }

    override init() {
        preferences = Preferences()
        
        super.init()
        
        if let statusButton = statusItem.button {
            let icon = NSImage(named: "StatusBarButtonImage")
            icon?.isTemplate = true // best for dark mode
            
            statusButton.image = icon
            //            button.action = #selector(self.statusBarButtonClicked(sender:))
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        buildStaticMenu()
        
        updateDynamicMenuItems()
        
        statusItem.menu = menu
        
        menu.delegate = self
    }
    
    
    func buildStaticMenu() {

        let prefMenu = NSMenuItem(title: "Preferences", action: #selector(openPreferences(sender:)), keyEquivalent: ",")
        prefMenu.target = self
        menu.addItem(prefMenu)
        
        menu.addItem(NSMenuItem.separator())
        
        let openHaMenu = NSMenuItem(title: "Open Home Assistant", action: #selector(openHA(sender:)), keyEquivalent: "")
        openHaMenu.target = self
        menu.addItem(openHaMenu)
        
        let openAbout = NSMenuItem(title: "About HA Menu", action: #selector(openAbout(sender:)), keyEquivalent: "")
        openAbout.target = self
        menu.addItem(openAbout)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HA Menu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
    }
    
    @objc func openHA(sender: NSMenuItem) {
        NSWorkspace.shared.open(NSURL(string: prefs.server)! as URL)
    }
    
    @objc func openAbout(sender: NSMenuItem) {
        let options = [String: Any]()
        NSApp.orderFrontStandardAboutPanel(options)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openPreferences(sender: NSMenuItem) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PrefsWindowController")) as? NSWindowController
        {
            windowController.showWindow(self)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func updateDynamicMenuItems() {
        removeMenuItems()
        getStates()
    }
    
    func getStates() {
        guard let url = URL(string: "\(prefs.server)/api/states") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(prefs.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([HaState].self, from: data) {
                    DispatchQueue.main.async {
                        self.haStates = decodedResponse

                        // Add a seperator before static menu items
                        self.menu.insertItem(NSMenuItem.separator(), at: 0)
                        
                        // Populate Menu
                        let allSwitches = self.getEntity(entityId: "group.all_switches")
                        for entityId in (allSwitches?.attributes!.entityIds!)! {
                            
                            let entity = self.getEntity(entityId: entityId)
                            let friendlyName = entity?.attributes!.friendlyName
                            let state = entity?.state
                            
                            let menuItem = NSMenuItem(title: friendlyName!, action: #selector(self.toggleSwitch(_:)), keyEquivalent: "")
                            menuItem.target = self
                            
                            menuItem.state = ((state == "on") ? NSControl.StateValue.on : NSControl.StateValue.off)
                            menuItem.representedObject = entityId
                            menuItem.tag = menuItemTypes.switchType.rawValue // Tag defines what type of item it is
                            //                    menuItem.image = NSImage(named: "StatusBarButtonImage")
                            //                    menuItem.offStateImage = NSImage(named: "NSMenuOnStateTemplate")
                            
                            self.menu.insertItem(menuItem, at: 0)
                        }

                    }
                }
                
                return
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }

    func removeMenuItems() {
        var switchMenu: NSMenuItem?
        repeat {
            switchMenu = self.menu.item(withTag: menuItemTypes.switchType.rawValue)
            if (switchMenu != nil) {
                self.menu.removeItem(switchMenu!)
            }
        } while switchMenu != nil
    }
    
    func getEntity(entityId: String) -> HaState? {
        return self.haStates?.first(where: {$0.entityId == entityId})
    }
    
    @objc func toggleSwitch(_ sender: NSMenuItem) {
        //        sender.representedObject
        let params = ["entity_id": sender.representedObject] as! Dictionary<String, String>
        
        var request = URLRequest(url: URL(string: "\(prefs.server)/api/services/switch/toggle")!)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(prefs.token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            //            print(response!)
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })
        
        task.resume()
    }
    
    public func menuWillOpen(_ menu: NSMenu){
        self.updateDynamicMenuItems()
    }
    
    public func menuDidClose(_ menu: NSMenu){
        
    }
}

