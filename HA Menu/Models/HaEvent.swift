//
//  HaEvent.swift
//  HA Menu
//
//  Created by Andrew Jackson on 26/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

struct HaEvent : Decodable {

    let eventType: String
    let entityId: String
//    let oldState: String
//    let newState: String
    let oldState: HaEventStateMedia
    let newState: HaEventStateMedia

    var isImageChanged: Bool {
        return oldState.entityPicture != newState.entityPicture
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case event = "event"
    }

    enum EventCodingKeys: String, CodingKey {
        case eventType = "event_type"
        case data = "data"
    }

    enum DataCodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case oldState = "old_state"
        case newState = "new_state"
    }

    init() {
        eventType = ""
        entityId = ""
        oldState = HaEventStateMedia()
        newState = HaEventStateMedia()
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let event = try values.nestedContainer(keyedBy: EventCodingKeys.self, forKey: .event)
        let data = try event.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)

        let eventType = try event.decodeIfPresent(String.self, forKey: .eventType)
        self.eventType = eventType ?? ""

        if self.eventType == "state_changed" {
            if let entityId = try data.decodeIfPresent(String.self, forKey: .entityId) {
                self.entityId = entityId
            } else {
                self.entityId = ""
            }

            if entityId.starts(with: "media_player.") {
                if let oldState = try data.decodeIfPresent(HaEventStateMedia.self, forKey: .oldState) {
                    self.oldState = oldState
                } else {
                    self.oldState = HaEventStateMedia()
                }

                if let newState = try data.decodeIfPresent(HaEventStateMedia.self, forKey: .newState) {
                    self.newState = newState
                } else {
                    self.newState = HaEventStateMedia()
                }
            }
            else {
                self.oldState = HaEventStateMedia()
                self.newState = HaEventStateMedia()
            }
        } else {
            entityId = ""
            oldState = HaEventStateMedia()
            newState = HaEventStateMedia()
        }

    }

}
