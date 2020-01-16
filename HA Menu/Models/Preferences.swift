//
//  Preferences.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct Preferences {

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
        }
    }

    var token: String {
        get {
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespaces), forKey: "token")
        }
    }

    var launch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "launch")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "launch")
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
        }
    }

    var domainSwitches: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_switches")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_switches")
        }
    }

    var domainAutomations: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_automations")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_automations")
        }
    }

    var domainInputbooleans: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "domain_inputbooleans")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "domain_inputbooleans")
        }
    }

}
