//
//  PrefMenuItem.swift
//  HA Menu
//
//  Created by Andrew Jackson on 28/01/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

enum menuItemTypes: String, Encodable, Decodable {
    case Domain = "Domain"
    case Group = "Group"
}

struct PrefMenuItem : Encodable, Decodable {
    var entityId: String
    var menuItemType: menuItemTypes
    var subMenu: Bool
    var enabled: Bool
}
