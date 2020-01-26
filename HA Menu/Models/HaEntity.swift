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
    case automationType = 5
    case inputSelectType = 6
    case groupType = 7
}

enum EntityDomains: String {
    case switchDomain = "switch"
    case lightDomain = "light"
    case inputBooleanDomain = "input_boolean"
    case automationDomain = "automation"
    case inputSelectDomain = "input_select"
    case groupDomain = "group"
}

struct HaEntity {

    var entityId : String
    var friendlyName: String
    var state: String
    var type: EntityTypes
    var options: [String]

    var domain: String {
        get {
            switch type {
            case .switchType:
                return EntityDomains.switchDomain.rawValue
            case .lightType:
                return EntityDomains.lightDomain.rawValue
            case .inputBooleanType:
                return EntityDomains.inputBooleanDomain.rawValue
            case .automationType:
                return EntityDomains.automationDomain.rawValue
            case .inputSelectType:
                return EntityDomains.inputSelectDomain.rawValue
            case .groupType:
                return EntityDomains.groupDomain.rawValue
            }
        }
    }
}
