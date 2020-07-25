//
//  HaSocketMessage.swift
//  HA Menu
//
//  Created by Andrew Jackson on 25/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

enum HaSocketMessageTypes: String, CaseIterable, Encodable {
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
}

//struct HaSocketMessage: Decodable, Encodable {
//
//    let type: HaSocketMessageTypes
//    let success: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case type = "type"
//        case success = "success"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//
//        if let typeString = try values.decodeIfPresent(String.self, forKey: .type) {
//            self.type = HaSocketMessageTypes(rawValue: typeString) ?? .unknown
//        }
//        else {
//            self.type = .unknown
//        }
//
//        let success = try values.decodeIfPresent(String.self, forKey: .success)
//        self.success = success == "true" ? true : false
//
//    }
//}

struct HaSocketMessageResult: Decodable {

    let id: Int
    let success: Bool
    let resultString: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case success = "success"
        case result = "result"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(Int.self, forKey: .id)

        let success = try values.decodeIfPresent(Bool.self, forKey: .success)
        self.success = success ?? false

        let result = try values.decodeIfPresent(String.self, forKey: .result)
        self.resultString = result ?? ""
    }

//    Received text: {"id": 1, "type": "result", "success": true, "result": null}

}

struct HaSocketMessageEvent: Decodable {
    let id: Int
    let event: String
    let eventType: String
    let timeFired: String
    let origin: String


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case event = "event"
        case eventType = "event_type"
        case timeFired = "time_fired"
        case origin = "origin"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(Int.self, forKey: .id)

        let event = try values.decodeIfPresent(String.self, forKey: .event)
        self.event = event ?? ""

        let eventType = try values.decodeIfPresent(String.self, forKey: .eventType)
        self.eventType = eventType ?? ""

        let timeFired = try values.decodeIfPresent(String.self, forKey: .timeFired)
        self.timeFired = timeFired ?? ""

        let origin = try values.decodeIfPresent(String.self, forKey: .origin)
        self.origin = origin ?? ""
    }
}

struct HaSocketMessageAuth: Encodable {

    let type = HaSocketMessageTypes.auth
    var accessToken: String

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case accessToken = "access_token"
    }

    var jsonString: String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }
            return json
        }
        catch {
            return nil
        }
    }
}

struct HaSocketMessageSubscribeEvents: Encodable {

    let type = HaSocketMessageTypes.subscribeEvents

    var id: Int
    var eventType: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case eventType = "event_type"
    }

    var jsonString: String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }
            return json
        }
        catch {
            return nil
        }
    }
}

struct HaSocketMessageUnsubscribeEvents: Encodable {

    let type = HaSocketMessageTypes.unsubscribeEvents

    var id: Int
    var subscriptionId: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case subscriptionId = "subscription"
    }

    var jsonString: String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }
            return json
        }
        catch {
            return nil
        }
    }
}

