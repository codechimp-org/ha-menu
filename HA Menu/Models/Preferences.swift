//
//  Preferences.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct Preferences {

    let defaultGroup = "all_switches"

    var server: String {
        get {
            return UserDefaults.standard.string(forKey: "server") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "server")
        }
    }

    var token: String {
        get {
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
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

    var group: String {
        get {
            let groupid = UserDefaults.standard.string(forKey: "group") ?? defaultGroup
            return (groupid.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ? defaultGroup : groupid)
        }
        set {
             UserDefaults.standard.set(newValue, forKey: "group")
         }
    }

}
