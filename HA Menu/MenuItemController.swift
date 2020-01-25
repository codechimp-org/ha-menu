//
//  MenuItemController
//  HA Menu
//
//  Created by Andrew Jackson on 07/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation
import Cocoa
import FeedKit

final class MenuItemController: NSObject, NSMenuDelegate {
    
    var prefs = Preferences()
    var haStates : [HaState]?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    
    var preferences: Preferences

    let menuItemTypeInfo = 997
    let menuItemTypeError = 999

    let releasesFeedURL = URL(string: "https://github.com/codechimp-org/ha-menu/releases.atom")!
    let releasesURL = URL(string: "https://github.com/codechimp-org/ha-menu/releases")!
    
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
        
        statusItem.menu = menu
        
        menu.delegate = self
    }

    public func menuWillOpen(_ menu: NSMenu){
        self.removeDynamicMenuItems()
        self.getStates()
        self.checkForUpdate()
    }

    public func menuDidClose(_ menu: NSMenu){

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

    @objc func openAppWebsite(sender: NSMenuItem) {
        NSWorkspace.shared.open(releasesURL)
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


                    //MARK: Domains
                    if (self.prefs.domainInputSelects) {
                        let inputSelects = self.filterEntities(entityDomain: EntityDomains.inputSelectDomain.rawValue, itemType: EntityTypes.inputSelectType)
                        if inputSelects.count > 0 {
                            self.addEntitiesToMenu(entities: inputSelects)
                        }
                    }

                    if (self.prefs.domainInputBooleans) {
                        let inputBooleans = self.filterEntities(entityDomain: EntityDomains.inputBooleanDomain.rawValue, itemType: EntityTypes.inputBooleanType)
                        if inputBooleans.count > 0 {
                            self.addEntitiesToMenu(entities: inputBooleans)
                        }
                    }

                    if (self.prefs.domainAutomations) {
                        let automations = self.filterEntities(entityDomain: EntityDomains.automationDomain.rawValue, itemType: EntityTypes.automationType)
                        if automations.count > 0 {
                            self.addEntitiesToMenu(entities: automations)
                        }
                    }

                    if (self.prefs.domainSwitches) {
                        let switches = self.filterEntities(entityDomain: EntityDomains.switchDomain.rawValue, itemType: EntityTypes.switchType)
                        if switches.count > 0 {
                            self.addEntitiesToMenu(entities: switches)
                        }
                    }

                    if (self.prefs.domainLights) {
                        let lights = self.filterEntities(entityDomain: EntityDomains.lightDomain.rawValue, itemType: EntityTypes.lightType)
                        if lights.count > 0 {
                            self.addEntitiesToMenu(entities: lights)
                        }
                    }


                    //MARK: Groups
                    // Iterate groups in preferences
                    for groupId in (self.prefs.groups) {
                        if groupId.count > 0 {

                            if let group = self.getEntity(entityId: "group.\(groupId)") {

                                // For each entity, get it's attributes and if available add to array
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
                                    case "input_select":
                                        itemType = EntityTypes.inputSelectType
                                    case "automation":
                                        itemType = EntityTypes.automationType
                                    default:
                                        itemType = nil
                                    }

                                    if itemType != nil {
                                        if let entity = self.getEntity(entityId: entityId) {
                                            var options = [String]()

                                            if itemType == EntityTypes.inputSelectType {
                                                options = entity.attributes.options
                                            }

                                            // Do not add unavailable state entities
                                            if (entity.state != "unavailable") {

                                                let haEntity: HaEntity = HaEntity(entityId: entityId, friendlyName: (entity.attributes.friendlyName), state: (entity.state), type: itemType!, options: options)

                                                entities.append(haEntity)
                                            }
                                        }
                                    }
                                }

                                entities = entities.reversed()

                                self.addEntitiesToMenu(entities: entities)
                            } else {
                                self.addErrorMenuItem(message: "Group \(groupId) not found")
                                return
                            }
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

            // Add a seperator before static menu items/previous group
            self.menu.insertItem(NSMenuItem.separator(), at: 0)

            if (entities.count == 0) {
                self.addErrorMenuItem(message: "No Entities")
                return
            }

            // Populate menu items for switches
            for haEntity in entities {
                self.addEntityMenuItem(haEntity: haEntity)
            }

        }
    }

    func addEntityMenuItem(haEntity: HaEntity) {

        if haEntity.type == EntityTypes.inputSelectType {
            let inputSelectMenuItem = NSMenuItem()
            inputSelectMenuItem.title = haEntity.friendlyName
            inputSelectMenuItem.tag = haEntity.type.rawValue
            self.menu.insertItem(inputSelectMenuItem, at: 0)

            let subMenu = NSMenu()
            self.menu.setSubmenu(subMenu, for: inputSelectMenuItem)

            for option in haEntity.options {
                let optionMenuItem = NSMenuItem()
                optionMenuItem.target = self
                optionMenuItem.title = option
                optionMenuItem.state = ((haEntity.state == option) ? NSControl.StateValue.on : NSControl.StateValue.off)
                optionMenuItem.action = #selector(self.selectInputSelectOption(_ :))
                optionMenuItem.representedObject = haEntity
                optionMenuItem.tag = haEntity.type.rawValue // Tag defines what type of item it is
                subMenu.addItem(optionMenuItem)
            }
        }
        else {
            let menuItem = NSMenuItem()
            menuItem.action = #selector(self.toggleEntityState(_:))
            menuItem.target = self
            menuItem.title = haEntity.friendlyName
            menuItem.keyEquivalent = ""
            menuItem.state = ((haEntity.state == "on") ? NSControl.StateValue.on : NSControl.StateValue.off)
            menuItem.representedObject = haEntity
            menuItem.tag = haEntity.type.rawValue // Tag defines what type of item it is
            //        menuItem.image = NSImage(named: "StatusBarButtonImage")
            //        menuItem.offStateImage = NSImage(named: "NSMenuOnStateTemplate")

            self.menu.insertItem(menuItem, at: 0)
        }
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

        // Info
        repeat {
            dynamicItem = self.menu.item(withTag: self.menuItemTypeInfo)
            if (dynamicItem != nil) {
                self.menu.removeItem(dynamicItem!)
            }
        } while dynamicItem != nil

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

    func filterEntities(entityDomain: String, itemType: EntityTypes) -> [HaEntity] {
        var entities = [HaEntity]()

        for haState in self.haStates! {
            if (haState.entityId.starts(with: entityDomain + ".")) {
                // Do not add unavailable state entities
                if (haState.state != "unavailable") {

                    let haEntity: HaEntity = HaEntity(entityId: haState.entityId, friendlyName: (haState.attributes.friendlyName), state: (haState.state), type: itemType, options: haState.attributes.options)

                    entities.append(haEntity)
                }
            }
        }

        entities = entities.sorted(by: {$0.friendlyName > $1.friendlyName})

        return entities
    }

    @objc func toggleEntityState(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity

        let params = ["entity_id": haEntity.entityId]

        var request = createAuthURLRequest(url: URL(string: "\(prefs.server)/api/services/\(haEntity.domain)/toggle")!)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    @objc func selectInputSelectOption(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity

        let params = ["entity_id": haEntity.entityId, "option": sender.title]

        var request = createAuthURLRequest(url: URL(string: "\(prefs.server)/api/services/input_select/select_option")!)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    func createAuthURLRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(prefs.token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func checkForUpdate() {
        let parser = FeedParser(URL: releasesFeedURL)

        parser.parseAsync { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let feed):

                if let latestId = (feed.atomFeed?.entries?.first?.id!) {
                    let idArray = latestId.components(separatedBy: "/")
                    let latestVersion = idArray.last

                    if (latestVersion?.hasSuffix("beta"))! {
                        return
                    }

                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

                    if (latestVersion != appVersion) {
                        DispatchQueue.main.async {
                            // Add a seperator before static menu items
                            self.menu.insertItem(NSMenuItem.separator(), at: 0)

                            let menuItem = NSMenuItem(title: "A new version is available", action: #selector(self.openAppWebsite(sender:)), keyEquivalent: "")
                            menuItem.target = self

                            menuItem.tag = self.menuItemTypeInfo // Tag defines what type of item it is
                            menuItem.image = NSImage(named: "InfoImage")

                            self.menu.insertItem(menuItem, at: 0)
                        }
                    }
                }
                else {
                    print("Unable to get release feed")
                }

            case .failure(let error):
                // Silently ignore
                print(error)
            }
        }
    }
}
