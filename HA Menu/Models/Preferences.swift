//
//  Preferences.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct Preferences {

    // Witham
    //    var server = "http://192.168.3.142:8123"
    //    var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJkNjBjOWUxNTVhMjA0OGY3YmFlNmM0MWM1MWZiYjdkYiIsImlhdCI6MTU0MDA1NTA1NSwiZXhwIjoxODU1NDE1MDU1fQ.gmE5MXpcLL7qKsDLddWlb5IflSi6GJm4Cej6BMBHpKA"

    // Ipswich
    //    var server = "http://192.168.1.25:8123"
    //    var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJlZmFiNDIzNjJhZTk0NmM3YThiNzIwZWFhYmI5ZGQzZiIsImlhdCI6MTU0MDY1ODk4NiwiZXhwIjoxODU2MDE4OTg2fQ.7A5tcAEehwDeg8hDViYbWKcf9wZGQ15areD9-naG5tw"

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
