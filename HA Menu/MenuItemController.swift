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
    var groups = [HaEntity]()
    var menuItems = [PrefMenuItem]()
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    
    var preferences: Preferences

    let menuItemAbout = 995
    let menuItemTypeTopLevel = 996
    let menuItemTypeInfo = 997
    let menuItemTypeError = 999

    let releasesFeedURL = URL(string: "https://github.com/codechimp-org/ha-menu/releases.atom")!
    let releasesURL = URL(string: "https://github.com/codechimp-org/ha-menu/releases")!
    
    override init() {
        preferences = Preferences()
        
        super.init()

        statusItem.autosaveName = "org.codechimp.hamenu.menu"
        
        if let statusButton = statusItem.button {
            #if DEBUG
            let icon = NSImage(named: "StatusBarHAButtonImageDebug")
            #else
            let icon = NSImage(named: "StatusBarHAButtonImage")
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
        self.removeDynamicMenuItems()

        self.addDynamicMenuItems(){
            result in
            switch result {
            case .success( _):
                self.checkForUpdate()
            case .failure( _):
                break
            }
        }
    }

    public func menuDidClose(_ menu: NSMenu){

    }
    
    func buildStaticMenu() {

        menu.addItem(NSMenuItem.separator())

        let prefMenu = NSMenuItem(title: "Preferences", action: #selector(openPreferences(sender:)), keyEquivalent: ",")
        prefMenu.target = self
        menu.addItem(prefMenu)
        
        menu.addItem(NSMenuItem.separator())
        
        let openHaMenu = NSMenuItem(title: "Open Home Assistant", action: #selector(openHA(sender:)), keyEquivalent: "")
        openHaMenu.target = self
        menu.addItem(openHaMenu)
        
        let openAbout = NSMenuItem(title: "About HA Menu", action: #selector(openAbout(sender:)), keyEquivalent: "")
        openAbout.tag = menuItemAbout
        openAbout.target = self
        menu.addItem(openAbout)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HA Menu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
    }

    @objc func openAppWebsite(sender: NSMenuItem) {
        NSWorkspace.shared.open(releasesURL)
    }

    @objc func openHA(sender: NSMenuItem) {

        if #available(OSX 10.15, *) {
            let url = NSURL(fileURLWithPath: "/Applications/Home Assistant.app", isDirectory: true) as URL

            let path = "/bin"
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.arguments = [path]
            configuration.promptsUserIfNeeded = false

            NSWorkspace.shared.openApplication(at: url,
                                               configuration: configuration) { (app, error) in
                                                if error != nil {
                                                    // Fallback to opening website
                                                    NSWorkspace.shared.open(NSURL(string: self.prefs.server)! as URL)
                                                }
            }

        } else {
            // Fallback on earlier versions
            if !NSWorkspace.shared.launchApplication("Home Assistant") {
                // Fallback to opening website
                NSWorkspace.shared.open(NSURL(string: self.prefs.server)! as URL)
            }

        }

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

    func addDynamicMenuItems(completionHandler: @escaping (Result<Bool, HaService.HaServiceApiError>) -> Void) {
        haService.getStates() {
            result in
            switch result {
            case .success( _):

                self.menuItems.removeAll()

                self.groups = self.haService.filterEntities(entityDomain: EntityDomains.groupDomain.rawValue).reversed()

                let menuItemsWithFriendlyNames = self.prefs.menuItemsWithFriendlyNames(groups: self.groups)

                let sortedMenuItemsWithFriendlyNames = menuItemsWithFriendlyNames.sorted { $0.value.index < $1.value.index }

                for (_, value) in sortedMenuItemsWithFriendlyNames {
                    self.menuItems.insert(value, at: 0)
                }

                // Add Menu Items
                var nextRequiresSeparator = true
                for menuItem in self.menuItems {
                    if menuItem.enabled {
                        nextRequiresSeparator = self.addMenuItem(menuItem: menuItem, requiresSeparator: nextRequiresSeparator)
                    }
                }
                completionHandler(.success(true))

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
                    self.addErrorMenuItem(message: "Unknown Error (check your server/port)")
                }
                completionHandler(.failure(haServiceApiError))
                break
            }
        }
    }

    func addMenuItem(menuItem: PrefMenuItem, requiresSeparator: Bool) -> Bool {
        var nextRequiresSeparator = false

        switch menuItem.itemType {
        case itemTypes.Domain:
            let domainItems = self.haService.filterEntities(entityDomain: menuItem.entityId)
            self.addMenuItem(menuItem: menuItem, entities: domainItems, requiresSeparator: requiresSeparator)

            nextRequiresSeparator = !menuItem.subMenu

        case itemTypes.Group:
            self.haService.getState(entityId: "group.\(menuItem.entityId)") { result in
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
                        case "scene":
                            itemType = EntityTypes.sceneType
                        case "script":
                            itemType = EntityTypes.scriptType
                        case "sensor":
                            itemType = EntityTypes.sensorType

                        default:
                            itemType = nil
                        }

                        if itemType != nil {

                            self.haService.getState(entityId: entityId) { result in
                                switch result {
                                case .success(let entity):
                                    var options = [String]()
                                    var unitOfMeasurement = ""

                                    if itemType == EntityTypes.inputSelectType {
                                        options = entity.attributes.options
                                    }

                                    if itemType == EntityTypes.sensorType {
                                        unitOfMeasurement = entity.attributes.unitOfMeasurement
                                    }
                                    
                                    // Do not add unavailable state entities
                                    if (entity.state != "unavailable") {

                                        let haEntity: HaEntity = HaEntity(entityId: entityId, friendlyName: (entity.attributes.friendlyName), state: (entity.state), unitOfMeasurement: unitOfMeasurement, options: options)

                                        entities.append(haEntity)
                                    }
                                case .failure( _):
                                    break
                                }
                            }
                        }
                    }

                    entities = entities.reversed()

                    self.addMenuItem(menuItem: menuItem, entities: entities, requiresSeparator: requiresSeparator)

                    nextRequiresSeparator = !menuItem.subMenu

                    break
                case .failure( _):
                    self.addErrorMenuItem(message: "Group not found")
                }
            }
        }

        return nextRequiresSeparator
    }

    func addMenuItem(menuItem: PrefMenuItem, entities: [HaEntity], requiresSeparator: Bool) {
        DispatchQueue.main.async {

            if entities.count == 0 {
                return
            }

            // Add a seperator before static menu items/previous group
            if (requiresSeparator || !menuItem.subMenu) {
                self.menu.insertItem(NSMenuItem.separator(), at: 0)
            }

            var parent = self.menu


            if menuItem.subMenu {
                let topMenuItem = NSMenuItem()
                topMenuItem.title = menuItem.friendlyName
                topMenuItem.tag = self.menuItemTypeTopLevel
                self.menu.insertItem(topMenuItem, at: 0)

                let subMenu = NSMenu()
                parent = subMenu
                self.menu.setSubmenu(subMenu, for: topMenuItem)
            }

            // Populate menu items
            for haEntity in entities {
                self.addEntityMenuItem(parent: parent, haEntity: haEntity)
            }

        }
    }

    func addEntityMenuItem(parent: NSMenu, haEntity: HaEntity) {

        if haEntity.domainType == EntityDomains.inputSelectDomain {
            let inputSelectMenuItem = NSMenuItem()
            inputSelectMenuItem.title = haEntity.friendlyName
            inputSelectMenuItem.tag = haEntity.type.rawValue
            parent.insertItem(inputSelectMenuItem, at: 0)

            let subMenu = NSMenu()
            parent.setSubmenu(subMenu, for: inputSelectMenuItem)

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

            menuItem.title = haEntity.friendlyName
            
            if haEntity.domainType == EntityDomains.sceneDomain {
                menuItem.action = #selector(self.turnOnEntity(_:))
                menuItem.state = NSControl.StateValue.off
                menuItem.offStateImage = NSImage(named: "PlayButtonImage")
            }
            else if haEntity.domainType == EntityDomains.scriptDomain {
                menuItem.action = #selector(self.turnOnEntity(_:))
                menuItem.state = NSControl.StateValue.off
                menuItem.offStateImage = NSImage(named: "PlayButtonImage")
            }
            else if haEntity.domainType == EntityDomains.sensorDomain {
                menuItem.title = haEntity.friendlyName + ": " + haEntity.state + haEntity.unitOfMeasurement
                menuItem.action = #selector(self.doNothing(_:))
                menuItem.state = NSControl.StateValue.off
                menuItem.offStateImage = NSImage(named: "BulletImage")
            }
            else {
                menuItem.action = #selector(self.toggleEntityState(_:))
                menuItem.state = ((haEntity.state == "on") ? NSControl.StateValue.on : NSControl.StateValue.off)
            }

            menuItem.target = self
            menuItem.keyEquivalent = ""
            menuItem.representedObject = haEntity
            menuItem.tag = haEntity.type.rawValue // Tag defines what type of item it is
            //        menuItem.image = NSImage(named: "StatusBarButtonImage")
            //        menuItem.offStateImage = NSImage(named: "NSMenuOnStateTemplate")

            parent.insertItem(menuItem, at: 0)
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

        // Top Level Menu
        repeat {
            dynamicItem = self.menu.item(withTag: self.menuItemTypeTopLevel)
            if (dynamicItem != nil) {
                self.menu.removeItem(dynamicItem!)
            }
        } while dynamicItem != nil

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

    @objc func doNothing(_ sender: NSMenuItem) {
        // fake menu responder
    }
    
    @objc func toggleEntityState(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity
        haService.toggleEntityState(haEntity: haEntity)
    }

    @objc func selectInputSelectOption(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity
        haService.selectInputSelectOption(haEntity: haEntity, option: sender.title)
    }

    @objc func turnOnEntity(_ sender: NSMenuItem) {
        let haEntity: HaEntity = sender.representedObject as! HaEntity
        haService.turnOnEntity(haEntity: haEntity)
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

                    var beta = false
                    if (latestVersion?.hasSuffix("beta"))! {
                        beta = true
                        if (!self.prefs.betaNotifications) {
                            return
                        }
                    }

                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

                    if (latestVersion != appVersion) {
                        DispatchQueue.main.async {
                            var title: String
                            if beta {
                                title = "A new beta version is available"
                            }
                            else
                            {
                                title = "A new version is available"
                            }
                            let menuItem = NSMenuItem(title: title, action: #selector(self.openAppWebsite(sender:)), keyEquivalent: "")
                            menuItem.target = self

                            menuItem.tag = self.menuItemTypeInfo // Tag defines what type of item it is
                            menuItem.image = NSImage(named: "InfoImage")

                            let position = self.menu.indexOfItem(withTag: self.menuItemAbout) + 1

                            self.menu.insertItem(menuItem, at: position)
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
