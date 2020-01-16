//
//  HaEntity.swift
//  HA Menu
//
//  Created by Andrew Jackson on 14/11/2019.
//  Copyright © 2019 CodeChimp. All rights reserved.
//

import Foundation

enum EntityTypes: Int, CaseIterable {
    case switchType = 2
    case lightType = 3
    case inputBooleanType = 4
    case automation = 5
}

enum EntityDomains: String {
    case switchDomain = "switch"
    case lightDomain = "light"
    case inputBooleanDomain = "input_boolean"
    case automationDomain = "automation"
}

struct HaEntity {

    var entityId : String
    var friendlyName: String
    var state: String
    var type: EntityTypes
}
