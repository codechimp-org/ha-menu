//
//  HaState.swift
//  HA Menu
//
//  Created by Andrew Jackson on 18/01/2023.
//

import Foundation

struct HaState : Decodable {

    let attributes : HaStateAttributes
    let entityId : String
    let state : String

    enum CodingKeys: String, CodingKey {
        case attributes = "attributes"
        case entityId = "entity_id"
        case state = "state"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)


        if let entityId = try values.decodeIfPresent(String.self, forKey: .entityId) {
            self.entityId = entityId
        } else {
            self.entityId = ""
        }

        if let state = try values.decodeIfPresent(String.self, forKey: .state) {
            self.state = state
        } else {
            self.state = ""
        }

        guard var attributes = try? HaStateAttributes(from: decoder) else {
            self.attributes = HaStateAttributes()
            return
        }

        if (attributes.friendlyName.isEmpty) {
            attributes.friendlyName = self.entityId
        }

        self.attributes = attributes
    }
}
