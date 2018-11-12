//
//  HaStateAttribute.swift
//  HA Menu
//
//  Created by Andrew Jackson on 05/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct HaStateAttribute : Decodable {

    let assumedState : Bool?
    let auto : Bool?
    let entityIds : [String]?
    let friendlyName : String?

    enum CodingKeys: String, CodingKey {
        case attributes
    }

    enum AttributeKeys: String, CodingKey {
        case assumedState = "assumed_state"
        case auto = "auto"
        case entityIds = "entity_id"
        case friendlyName = "friendly_name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let attributes = try values.nestedContainer(keyedBy: AttributeKeys.self, forKey: .attributes)
        self.assumedState = try attributes.decodeIfPresent(Bool.self, forKey: .assumedState)
        self.auto = try attributes.decodeIfPresent(Bool.self, forKey: .auto)
        self.entityIds = try attributes.decodeIfPresent([String].self, forKey: .entityIds)
        self.friendlyName = try attributes.decodeIfPresent(String.self, forKey: .friendlyName)
    }

}
