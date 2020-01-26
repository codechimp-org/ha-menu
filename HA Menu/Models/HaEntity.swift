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
    case unknownType = 999
}

enum EntityDomains: String, CaseIterable {
    case switchDomain = "switch"
    case lightDomain = "light"
    case inputBooleanDomain = "input_boolean"
    case automationDomain = "automation"
    case inputSelectDomain = "input_select"
    case groupDomain = "group"
    case unknownDomain = "unknown"
}

struct HaEntity {

    var entityId: String
    var friendlyName: String
    var state: String
    var options: [String]

    var domain: String {
        get {
            return entityId.components(separatedBy: ".")[0]
        }
    }

    var type: EntityTypes {
        get {
            switch domain{
            case EntityDomains.switchDomain.rawValue:
                return EntityTypes.switchType
            case EntityDomains.lightDomain.rawValue:
                return EntityTypes.lightType
            case EntityDomains.inputBooleanDomain.rawValue:
                return EntityTypes.inputBooleanType
            case EntityDomains.automationDomain.rawValue:
                return EntityTypes.automationType
            case EntityDomains.inputSelectDomain.rawValue:
                return EntityTypes.inputSelectType
            case EntityDomains.groupDomain.rawValue:
                 return EntityTypes.groupType
            default:
                return EntityTypes.unknownType
        }
    }
    }
}
