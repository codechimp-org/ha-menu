//
//  PrefMenuItem.swift
//  HA Menu
//
//  Created by Andrew Jackson on 28/01/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

enum itemTypes: String, Codable {
    case Domain = "Domain"
    case Group = "Group"
}

struct PrefMenuItem : Codable {
    var entityId: String
    var itemType: itemTypes
    var subMenu: Bool
    var enabled: Bool
    var friendlyName: String?
    var index: Int = 0

    private enum CodingKeys: String, CodingKey {
        case entityId, itemType, subMenu, enabled
    }
}
