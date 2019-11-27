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

    let menuItemTypeError = 999

    
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
        
        var request = createAuthURLRequest(url: url)
        
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

                    // Iterate groups in preferences
                    for groupId in (self.prefs.groups) {

                        if let group = self.getEntity(entityId: "group.\(groupId)") {

                            // For each switch entity, get it's attributes and if available add to switches array
                            var entities = [HaEntity]()

                            for entityId in (group.attributes.entityIds) {

                                let entityType = entityId.components(separatedBy: ".")[0]
                                var itemType: EntityTypes?

                                switch entityType {
                                case "switch":
                                    itemType = EntityTypes.switchType
                                case "light":
                                    itemType = EntityTypes.lightType
                                case "input_boolean":
                                    itemType = EntityTypes.inputBooleanType
                                default:
                                    itemType = nil
                                }

                                if itemType != nil {
                                    if let entity = self.getEntity(entityId: entityId) {

                                        // Do not add unavailable state entities
                                        if (entity.state != "unavailable") {

                                            let haEntity: HaEntity = HaEntity(entityId: entityId, friendlyName: (entity.attributes.friendlyName), state: (entity.state), type: itemType! )

                                            entities.append(haEntity)
                                        }
                                    }
                                }
                            }

                            self.addEntitiesToMenu(entities: entities)
                        } else {
                            self.addErrorMenuItem(message: "Group \(groupId) not found")
                            return
                        }
                    }

                } catch {
                    self.addErrorMenuItem(message: error.localizedDescription)
                }
                return
            }

            self.addErrorMenuItem(message: error?.localizedDescription ?? "Unknown error")

        }.resume()
    }

    func addEntitiesToMenu(entities: [HaEntity]) {
        DispatchQueue.main.async {
            let sortedEntities = entities.sorted(by: {$0.friendlyName > $1.friendlyName})

            if (sortedEntities.count == 0) {
                self.addErrorMenuItem(message: "No Entities")
                return
            }

            // Add a seperator before static menu items/previous group
            self.menu.insertItem(NSMenuItem.separator(), at: 0)

            // Populate menu items for switches
            for haEntity in sortedEntities {
                self.addEntityMenuItem(haEntity: haEntity)
            }

        }
    }

    func addEntityMenuItem(haEntity: HaEntity) {
        let menuItem = NSMenuItem()

        switch haEntity.type {
        case EntityTypes.switchType:
            menuItem.action = #selector(self.toggleSwitch(_:))
        case EntityTypes.lightType:
            menuItem.action = #selector(self.toggleLight(_:))
        case EntityTypes.inputBooleanType:
            menuItem.action = #selector(self.toggleInputBoolean(_:))
        }

        menuItem.target = self
        menuItem.title = haEntity.friendlyName
        menuItem.keyEquivalent = ""
        menuItem.state = ((haEntity.state == "on") ? NSControl.StateValue.on : NSControl.StateValue.off)
        menuItem.representedObject = haEntity.entityId
        menuItem.tag = haEntity.type.rawValue // Tag defines what type of item it is
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

            menuItem.tag = self.menuItemTypeError // Tag defines what type of item it is
            menuItem.image = NSImage(named: "ErrorImage")

            self.menu.insertItem(menuItem, at: 0)
        }
    }

    func removeDynamicMenuItems() {
        var dynamicItem: NSMenuItem?

        // Entities
        for type in EntityTypes.allCases {
            repeat {
                dynamicItem = self.menu.item(withTag: type.rawValue)
                if (dynamicItem != nil) {
                    self.menu.removeItem(dynamicItem!)
                }
            } while dynamicItem != nil
        }

        // Errors
        repeat {
            dynamicItem = self.menu.item(withTag: self.menuItemTypeError)
            if (dynamicItem != nil) {
                self.menu.removeItem(dynamicItem!)
            }
        } while dynamicItem != nil

        // Remove the top seperators
        while self.menu.item(at: 0) == NSMenuItem.separator() {
            self.menu.removeItem(at: 0)
        }
    }

    func getEntity(entityId: String) -> HaState? {
        return self.haStates?.first(where: {$0.entityId == entityId})
    }

    @objc func toggleSwitch(_ sender: NSMenuItem) {
        let params = ["entity_id": sender.representedObject] as! Dictionary<String, String>

        var request = createAuthURLRequest(url: URL(string: "\(prefs.server)/api/services/switch/toggle")!)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    @objc func toggleLight(_ sender: NSMenuItem) {
        let params = ["entity_id": sender.representedObject] as! Dictionary<String, String>

        var request = createAuthURLRequest(url: URL(string: "\(prefs.server)/api/services/light/toggle")!)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    @objc func toggleInputBoolean(_ sender: NSMenuItem) {
        let params = ["entity_id": sender.representedObject] as! Dictionary<String, String>

        var request = createAuthURLRequest(url: URL(string: "\(prefs.server)/api/services/input_boolean/toggle")!)

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

    func createAuthURLRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(prefs.token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
