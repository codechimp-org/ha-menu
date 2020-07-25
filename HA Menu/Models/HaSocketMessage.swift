//
//  HaSocketMessage.swift
//  HA Menu
//
//  Created by Andrew Jackson on 25/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

struct HaSocketMessage: Decodable, Encodable {

    enum Types: String, CaseIterable, Encodable {

        case authRequired = "auth_required"
        case auth = "auth"
        case authOk = "auth_ok"
        case authInvalid = "auth_invalid"
        case result = "result"
        case subscribeEvents = "subscribe_events"
        case unsubscribeEvents = "unsubscribe_events"
        case event = "event"
        case callService = "call_service"
        case getStates = "get_states"
        case getConfig = "get_config"
        case getServices = "get_services"
        case getPanels = "get_panels"
        case mediaPlayerThumbnail = "media_player_thumbnail"
        case ping = "ping"
        case pong = "pong"


        case unknown = "unknown"

        static func withLabel(_ label: String) -> Types? {
            return self.allCases.first{ "\($0)" == label }
        }
    }

    let type: Types
    let success: Bool

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case success = "success"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)


        if let typeString = try values.decodeIfPresent(String.self, forKey: .type) {
            self.type = Types(rawValue: typeString) ?? .unknown

        }
        else {
            self.type = .unknown
        }

        let success = try values.decodeIfPresent(String.self, forKey: .success)
        self.success = success == "true" ? true : false

    }
}
