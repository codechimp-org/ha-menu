//
//  HaStateAttributes.swift
//  HA Menu
//
//  Created by Andrew Jackson on 05/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct HaStateAttributes : Decodable {

    let entityIds: [String]
    var friendlyName: String // Allow rewriting to entityId when decoded
    let options: [String]

    enum CodingKeys: String, CodingKey {
        case attributes
    }

    enum AttributeKeys: String, CodingKey {
        case entityIds = "entity_id"
        case friendlyName = "friendly_name"
        case options = "options"
    }

    init() {
        entityIds = [String]()
        friendlyName = ""
        options = [String]()
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
            self.friendlyName = ""
        }

        if let options = try attributes.decodeIfPresent([String].self, forKey: .options) {
            self.options = options
        } else {
            self.options = [String]()
        }
    }

}
