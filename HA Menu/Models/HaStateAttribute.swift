//
//  HaStateAttribute.swift
//  HA Menu
//
//  Created by Andrew Jackson on 05/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct HaStateAttribute : Decodable {

    let entityIds : [String]
    let friendlyName : String

    enum CodingKeys: String, CodingKey {
        case attributes
    }

    enum AttributeKeys: String, CodingKey {
        case entityIds = "entity_id"
        case friendlyName = "friendly_name"
    }

    init() {
        entityIds = [String]()
        friendlyName = ""
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let attributes = try values.nestedContainer(keyedBy: AttributeKeys.self, forKey: .attributes)
        if let entityIds = try attributes.decodeIfPresent([String].self, forKey: .entityIds) {
            self.entityIds = entityIds
        } else {
            self.entityIds = [String]()
        }

        if let friendlyName = try attributes.decodeIfPresent(String.self, forKey: .friendlyName) {
            self.friendlyName = friendlyName
        } else {
            self.friendlyName = "Unknown"
        }
    }

}
