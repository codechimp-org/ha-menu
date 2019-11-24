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
    let state : String?

    enum CodingKeys: String, CodingKey {
        case attributes = "attributes"
        case entityId = "entity_id"
        case state = "state"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try HaStateAttribute(from: decoder)

        entityId = try values.decodeIfPresent(String.self, forKey: .entityId)
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }
}
