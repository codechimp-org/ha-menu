//
//  HaStates.swift
//  HA Menu
//
//  Created by Andrew Jackson on 05/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Foundation

struct HaState : Decodable {

    let attributes : HaStateAttribute?
    let entityId : String?
    let lastChanged : String?
    let lastUpdated : String?
    let state : String?

    enum CodingKeys: String, CodingKey {
        case attributes = "attributes"
        case entityId = "entity_id"
        case lastChanged = "last_changed"
        case lastUpdated = "last_updated"
        case state = "state"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try HaStateAttribute(from: decoder)

        entityId = try values.decodeIfPresent(String.self, forKey: .entityId)
        lastChanged = try values.decodeIfPresent(String.self, forKey: .lastChanged)
        lastUpdated = try values.decodeIfPresent(String.self, forKey: .lastUpdated)
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }
}
