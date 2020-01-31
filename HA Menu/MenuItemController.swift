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

    var haService = HaService.shared
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
        self.addDynamicMenuItems()
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

    func addDynamicMenuItems() {
        haService.getStates() {
            result in
            switch result {
            case .success( _):
                self.addDomains()
                self.addGroups()

            case .failure(let haServiceApiError):
                switch haServiceApiError {
                case .URLMissing:
                    self.addErrorMenuItem(message: "Server URL missing")
                case .InvalidURL:
                    self.addErrorMenuItem(message: "Invalid URL")
                case .Unauthorized:
                    self.addErrorMenuItem(message: "Unauthorized")
                case .NotFound:
                    self.addErrorMenuItem(message: "Not Found")
                case .UnknownResponse:
                    self.addErrorMenuItem(message: "Unknown Response")
                case .JSONDecodeError:
                    self.addErrorMenuItem(message: "Error Decoding JSON")
                case .UnknownError:
                    self.addErrorMenuItem(message: "Unknown Error")
                }
                break
            }
        }
    }

    func addDomains() {
        if (self.prefs.domainInputSelects) {
            let inputSelects = self.haService.filterEntities(entityDomain: EntityDomains.inputSelectDomain.rawValue)
            if inputSelects.count > 0 {
                self.addEntitiesToMenu(entities: inputSelects)
            }
        }

        if (self.prefs.domainInputBooleans) {
            let inputBooleans = self.haService.filterEntities(entityDomain: EntityDomains.inputBooleanDomain.rawValue)
            if inputBooleans.count > 0 {
                self.addEntitiesToMenu(entities: inputBooleans)
            }
        }

        if (self.prefs.domainAutomations) {
            let automations = self.haService.filterEntities(entityDomain: EntityDomains.automationDomain.rawValue)
            if automations.count > 0 {
                self.addEntitiesToMenu(entities: automations)
            }
        }

        if (self.prefs.domainSwitches) {
            let switches = self.haService.filterEntities(entityDomain: EntityDomains.switchDomain.rawValue)
            if switches.count > 0 {
                self.addEntitiesToMenu(entities: switches)
            }
        }

        if (self.prefs.domainLights) {
            let lights = self.haService.filterEntities(entityDomain: EntityDomains.lightDomain.rawValue)
            if lights.count > 0 {
                self.addEntitiesToMenu(entities: lights)
            }
        }
    }

    func addGroups() {
        // Iterate groups in preferences
        for groupId in (self.prefs.groups) {
            if groupId.count > 0 {

                self.haService.getState(entityId: "group.\(groupId)") { result in
                    switch result {
                    case .success(let group):
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

                                self.haService.getState(entityId: entityId) { result in
                                    switch result {
                                    case .success(let entity):
                                        let options = [String]()

                                        // Do not add unavailable state entities
                                        if (entity.state != "unavailable") {

                                            let haEntity: HaEntity = HaEntity(entityId: entityId, friendlyName: (entity.attributes.friendlyName), state: (entity.state), options: options)

                                            entities.append(haEntity)
                                        }
                                    case .failure( _):
                                        break
                                    }
                                }
                            }
                        }

                        entities = entities.reversed()

                        self.addEntitiesToMenu(entities: entities)

                        break
                    case .failure( _):
                        self.addErrorMenuItem(message: "Group not found")
                    }
                }
            }
        }
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

        if haEntity.domain.rawValue == "inputselect" {
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

    @objc func toggleEntityState(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity
        haService.toggleEntityState(haEntity: haEntity)
    }

    @objc func selectInputSelectOption(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity
        haService.selectInputSelectOption(haEntity: haEntity, option: sender.title)
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
