//
//  Preferences.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct Preferences {

    var settingsVersion: Int {
        get {
            return UserDefaults.standard.integer(forKey: "settingsVersion")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "settingsVersion")
            UserDefaults.standard.synchronize()
        }
    }

    var server: String {
        get {
            var serverUrl = UserDefaults.standard.string(forKey: "server") ?? ""
            // Remove trailing slash
            if (serverUrl.hasSuffix("/")) {
                serverUrl.remove(at: serverUrl.index(before: serverUrl.endIndex))
            }
            return serverUrl
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespaces), forKey: "server")
            UserDefaults.standard.synchronize()
        }
    }

    var token: String {
        get {
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespaces), forKey: "token")
            UserDefaults.standard.synchronize()
        }
    }

    var launch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "launch")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "launch")
            UserDefaults.standard.synchronize()
        }
    }

    var betaNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "betaNotifications")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "betaNotifications")
            UserDefaults.standard.synchronize()
        }
    }

    var groupList: String {
        get {
            var groupList = UserDefaults.standard.string(forKey: "group") ?? ""

            // remove all_* groups that are deprecated, we use domains now
            groupList = groupList.replacingOccurrences(of: "all_lights", with: "")
            groupList = groupList.replacingOccurrences(of: "all_switches", with: "")
            groupList = groupList.replacingOccurrences(of: "all_automations", with: "")

            // replace spaces with commas, remove duplicated commas
            groupList = groupList.replacingOccurrences(of: " ", with: ",")
            groupList = groupList.replacingOccurrences(of: ",,", with: ",")

            // remove leading/trailing commas
            if (groupList.hasPrefix(",")) {
                groupList = String(groupList.dropFirst())
            }
            if (groupList.hasSuffix(",")) {
                groupList = String(groupList.dropLast())
            }

            return (groupList)
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespaces), forKey: "group")
            UserDefaults.standard.synchronize()
        }
    }

    var groups: [String] {

        var groupArray = [String]()

        // create array of groups, reverse order
        groupArray = self.groupList.components(separatedBy: ",")
        groupArray.reverse()

        return groupArray
    }

    var domainLights: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_lights")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_lights")
            UserDefaults.standard.synchronize()
        }
    }

    var domainSwitches: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_switches")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_switches")
            UserDefaults.standard.synchronize()
        }
    }

    var domainAutomations: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_automations")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_automations")
            UserDefaults.standard.synchronize()
        }
    }

    var domainInputBooleans: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_inputbooleans")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_inputbooleans")
            UserDefaults.standard.synchronize()
        }
    }

    var domainInputSelects: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_inputselects")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_inputselects")
            UserDefaults.standard.synchronize()
        }
    }

    var domainScenes: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_scenes")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_scenes")
            UserDefaults.standard.synchronize()
        }
    }

    var domainScripts: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_scripts")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_scripts")
            UserDefaults.standard.synchronize()
        }
    }

    var domainMediaPlayers: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_mediaplayers")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_mediaplayers")
            UserDefaults.standard.synchronize()
        }
    }

    var menuItems: [PrefMenuItem] {
        get {
            var decodedResponse = [PrefMenuItem]()

            // Check if string empty
            var jsonString = UserDefaults.standard.string(forKey: "menu_items") ?? ""

            if !jsonString.isEmpty {
                // Got JSON
                do {
                    let jsonData = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    decodedResponse = try JSONDecoder().decode([PrefMenuItem].self, from: jsonData!)

                    // Upgrade with any new domains
                    if !domainExists(domain: "scene", prefs: decodedResponse) {
                        decodedResponse.append(PrefMenuItem(entityId: "scene", itemType: itemTypes.Domain, subMenu: true, enabled: domainScenes, friendlyName: "Scenes"))
                    }

                    if !domainExists(domain: "script", prefs: decodedResponse) {
                        decodedResponse.append(PrefMenuItem(entityId: "script", itemType: itemTypes.Domain, subMenu: true, enabled: domainScenes, friendlyName: "Scripts"))
                    }

                    if !domainExists(domain: "media_player", prefs: decodedResponse) {
                        decodedResponse.append(PrefMenuItem(entityId: "media_player", itemType: itemTypes.Domain, subMenu: true, enabled: domainMediaPlayers, friendlyName: "Media Players"))
                    }

                    return decodedResponse
                }
                catch {
                    // Something odd with json, blank it out and default
                    jsonString = ""
                }
            }

            if jsonString.isEmpty {
                // Init Domains
                decodedResponse.append(PrefMenuItem(entityId: "light", itemType: itemTypes.Domain, subMenu: true, enabled: domainLights, friendlyName: "Lights"))

                decodedResponse.append(PrefMenuItem(entityId: "switch", itemType: itemTypes.Domain, subMenu: true, enabled: domainSwitches, friendlyName: "Switches"))

                decodedResponse.append(PrefMenuItem(entityId: "automation", itemType: itemTypes.Domain, subMenu: true, enabled: domainAutomations, friendlyName: "Automations"))

                decodedResponse.append(PrefMenuItem(entityId: "input_boolean", itemType: itemTypes.Domain, subMenu: true, enabled: domainInputBooleans, friendlyName: "Input Booleans"))

                decodedResponse.append(PrefMenuItem(entityId: "input_select", itemType: itemTypes.Domain, subMenu: true, enabled: domainInputSelects, friendlyName: "Input Selects"))

                decodedResponse.append(PrefMenuItem(entityId: "scene", itemType: itemTypes.Domain, subMenu: true, enabled: domainScenes, friendlyName: "Scenes"))

                decodedResponse.append(PrefMenuItem(entityId: "script", itemType: itemTypes.Domain, subMenu: true, enabled: domainScripts, friendlyName: "Scripts"))

                decodedResponse.append(PrefMenuItem(entityId: "media_player", itemType: itemTypes.Domain, subMenu: true, enabled: domainMediaPlayers, friendlyName: "Media Players"))

                // Init Groups from old setting
                for group in groups {
                    decodedResponse.append(PrefMenuItem(entityId: group, itemType: itemTypes.Group, subMenu: false, enabled: true, friendlyName: ""))
                }
                
                return decodedResponse
            }

            return decodedResponse
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                let dataString = String(data: data, encoding: .utf8)!
                UserDefaults.standard.set(dataString, forKey: "menu_items")

                settingsVersion = 2
            }
            catch {
                // Error encoding json, don't write new value
            }
        }
    }

    private func domainExists(domain: String, prefs: [PrefMenuItem]) -> Bool {
        var foundDomain = false

        for prefMenuItem in prefs {
            if prefMenuItem.entityId == domain {
                foundDomain = true
                break
            }
        }

        return foundDomain
    }

    func menuItemsWithFriendlyNames(groups: [HaEntity]) -> [String: PrefMenuItem] {
        var completedItems = [String: PrefMenuItem]()

        var index = 0

        for item in menuItems {

            if item.itemType == itemTypes.Group {
                // Check if still a group
                if let group = getGroup(groups: groups, entityId: "group." + item.entityId) {
                    index+=1

                    let completedItem = PrefMenuItem(entityId: item.entityId, itemType: item.itemType, subMenu: item.subMenu, enabled: item.enabled, friendlyName: group.friendlyName, index: index)

                    completedItems[completedItem.entityId] = completedItem
                }
            }
            else {
                index+=1
                var domainItem = item
                domainItem.index = index
                completedItems[item.entityId] = domainItem
            }
        }

        // Add missing groups
        for group in groups {
            if completedItems[group.entityIdNoPrefix] == nil {
                index+=1
                let completedItem = PrefMenuItem(entityId: group.entityIdNoPrefix, itemType: itemTypes.Group, subMenu: false, enabled: false, friendlyName: group.friendlyName, index: index)

                completedItems[group.entityIdNoPrefix] = completedItem
            }
        }

        return completedItems
    }

    private func getGroup(groups: [HaEntity], entityId: String) -> HaEntity? {
        for g in groups {
            if g.entityId == entityId {
                return g
            }
        }
        return nil
    }

}
