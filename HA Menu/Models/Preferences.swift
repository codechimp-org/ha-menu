//
//  Preferences.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct Preferences {

    let defaultGroupList = "all_switches,all_lights"

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
            var groupList = UserDefaults.standard.string(forKey: "group") ?? defaultGroupList

            // replace spaces with commas, remove duplicated commas
            groupList = groupList.replacingOccurrences(of: " ", with: ",")
            groupList = groupList.replacingOccurrences(of: ",,", with: ",")

            return (groupList.count == 0 ? defaultGroupList : groupList)
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
}
