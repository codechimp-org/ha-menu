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
        
        case errorType = 999
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
            NSApp.runModal(for: windowController.window!)

            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func updateDynamicMenuItems() {
        removeDynamicMenuItems()
        getStates()
    }
    
    func getStates() {
        if (prefs.server.count == 0 ) {
            self.addErrorMenuItem(message: "Server URL missing")
            return
        }
        
        guard let url = URL(string: "\(prefs.server)/api/states") else {
            self.addErrorMenuItem(message: "Invalid URL")
            return
        }
        
        var request = createAuthRequest(url: url)
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)

                if httpResponse.statusCode != 200 {
                    var errorMessage: String

                    switch httpResponse.statusCode {
                    case 401:
                        errorMessage = "401 - Unauthorized"
                    case 404:
                        errorMessage = "404 - Not Found"
                    default:
                        errorMessage = "\(httpResponse.statusCode) - Unknown Response"
                    }

                    self.addErrorMenuItem(message: errorMessage)

                    return
                }
            }

            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([HaState].self, from: data)
                    self.haStates = decodedResponse

                    let group = self.getEntity(entityId: "group.\(self.prefs.group)")

                    if (group == nil) {
                        self.addErrorMenuItem(message: "Group not found")
                        return
                    }

                    // For each switch entity, get it's attributes and if available add to switches array
                    var switches = [HaSwitch]()

                    for entityId in (group?.attributes!.entityIds!)! {
                        if (entityId.starts(with: "switch.")) {
                            let entity = self.getEntity(entityId: entityId)

                            // Do not add unavailable switches
                            if (entity?.state != "unavailable") {

                                let haSwitch: HaSwitch = HaSwitch(entityId: entityId, friendlyName: (entity?.attributes!.friendlyName)!, state: (entity?.state)!)

                                switches.append(haSwitch)
                            }
                        }
                    }

                    self.addSwitchesToMenu(switches: switches)

                } catch {
                    self.addErrorMenuItem(message: error.localizedDescription)
                }
                return
            }

            self.addErrorMenuItem(message: error?.localizedDescription ?? "Unknown error")

        }.resume()
    }

    func addSwitchesToMenu(switches: [HaSwitch]) {
        DispatchQueue.main.async {
            let sortedSwitches = switches.sorted(by: {$0.friendlyName > $1.friendlyName})

            if (sortedSwitches.count == 0) {
                self.addErrorMenuItem(message: "No Switches")
                return
            }

            // Add a seperator before static menu items
            self.menu.insertItem(NSMenuItem.separator(), at: 0)

            // Populate menu items for switches
            for haSwitch in sortedSwitches {
                self.addSwitchMenuItem(haSwitch: haSwitch)
            }

        }
    }

    func addSwitchMenuItem(haSwitch: HaSwitch) {
        let menuItem = NSMenuItem(title: haSwitch.friendlyName, action: #selector(self.toggleSwitch(_:)), keyEquivalent: "")
        menuItem.target = self

        menuItem.state = ((haSwitch.state == "on") ? NSControl.StateValue.on : NSControl.StateValue.off)
        menuItem.representedObject = haSwitch.entityId
        menuItem.tag = menuItemTypes.switchType.rawValue // Tag defines what type of item it is
//        menuItem.image = NSImage(named: "StatusBarButtonImage")
//        menuItem.offStateImage = NSImage(named: "NSMenuOnStateTemplate")

        self.menu.insertItem(menuItem, at: 0)
    }

    func addErrorMenuItem(message: String) {
        DispatchQueue.main.async {
            // Add a seperator before static menu items
            self.menu.insertItem(NSMenuItem.separator(), at: 0)

            let menuItem = NSMenuItem(title: message, action: #selector(self.openPreferences(sender:)), keyEquivalent: "")
            menuItem.target = self

            menuItem.tag = menuItemTypes.errorType.rawValue // Tag defines what type of item it is
            menuItem.image = NSImage(named: "ErrorImage")

            self.menu.insertItem(menuItem, at: 0)
        }
    }

    func removeDynamicMenuItems() {
        var switchMenu: NSMenuItem?

        // Switches
        repeat {
            switchMenu = self.menu.item(withTag: menuItemTypes.switchType.rawValue)
            if (switchMenu != nil) {
                self.menu.removeItem(switchMenu!)
            }
        } while switchMenu != nil

        // Errors
        repeat {
            switchMenu = self.menu.item(withTag: menuItemTypes.errorType.rawValue)
            if (switchMenu != nil) {
                self.menu.removeItem(switchMenu!)
            }
        } while switchMenu != nil

        // Remove the top seperator
        if (self.menu.item(at: 0) == NSMenuItem.separator()) {
            self.menu.removeItem(at: 0)
        }
    }

    func getEntity(entityId: String) -> HaState? {
        return self.haStates?.first(where: {$0.entityId == entityId})
    }

    @objc func toggleSwitch(_ sender: NSMenuItem) {
        let params = ["entity_id": sender.representedObject] as! Dictionary<String, String>

        var request = createAuthRequest(url: URL(string: "\(prefs.server)/api/services/switch/toggle")!)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    public func menuWillOpen(_ menu: NSMenu){
        self.updateDynamicMenuItems()
    }

    public func menuDidClose(_ menu: NSMenu){

    }

    func createAuthRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(prefs.token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
