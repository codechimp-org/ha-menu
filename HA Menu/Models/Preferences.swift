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
            if(UserDefaults.standard.value(forKey: "server") == nil) {
                return ""
            }
            else
            {
                return UserDefaults.standard.string(forKey: "server")!
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "server")
        }
    }

    var token: String {
        get {
            if(UserDefaults.standard.value(forKey: "token") == nil) {
                return ""
            }
            else
            {
                return UserDefaults.standard.string(forKey: "token")!
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }

}
