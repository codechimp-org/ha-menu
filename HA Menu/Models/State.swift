//
//  States.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on October 22, 2018

import Foundation

struct State : Decodable {

    let attributes : Attribute?
    let context : Context?
    let entityId : String?
    let lastChanged : String?
    let lastUpdated : String?
    let state : String?

    enum CodingKeys: String, CodingKey {
        case attributes = "attributes"
        case context = "context"
        case entityId = "entity_id"
        case lastChanged = "last_changed"
        case lastUpdated = "last_updated"
        case state = "state"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try Attribute(from: decoder)
        context = try Context(from: decoder)
        entityId = try values.decodeIfPresent(String.self, forKey: .entityId)
        lastChanged = try values.decodeIfPresent(String.self, forKey: .lastChanged)
        lastUpdated = try values.decodeIfPresent(String.self, forKey: .lastUpdated)
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }

}
