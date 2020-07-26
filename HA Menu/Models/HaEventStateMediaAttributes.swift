//
//  HaEventStateMediaAttributes.swift
//  HA Menu
//
//  Created by Andrew Jackson on 26/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

struct HaEventStateMedia : Decodable {

    let state: String

    var friendlyName: String // Allow rewriting to entityId when decoded
    let volumeLevel: Float
    let isVolumeMuted: Bool
    let mediaContentId: String
    let mediaContentType: String
    let mediaDuration: Int
    let mediaPosition: Int
    let mediaPositionUpdatedAt: String
    let mediaTitle: String
    let mediaArtist: String
    let mediaAlbumName: String
    let shuffle: String
    let entityPicture: String


    enum CodingKeys: String, CodingKey {
        case state
        case attributes
    }

    enum AttributeKeys: String, CodingKey {
        case friendlyName = "friendly_name"
        case volumeLevel = "volume_level"
        case isVolumeMuted = "is_volume_muted"
        case mediaContentId = "media_content_id"
        case mediaContentType = "media_content_type"
        case mediaDuration = "media_duration"
        case mediaPosition = "media_position"
        case mediaPositionUpdatedAt = "media_postition_update_at"
        case mediaTitle = "media_title"
        case mediaArtist = "media_artist"
        case mediaAlbumName = "media_album_name"
        case shuffle = "shuffle"
        case entityPicture = "entity_picture"
    }

    init() {
        state = ""

        friendlyName = ""
        volumeLevel = 0
        isVolumeMuted = false
        mediaContentId = ""
        mediaContentType = ""
        mediaDuration = 0
        mediaPosition = 0
        mediaPositionUpdatedAt = ""
        mediaTitle = ""
        mediaArtist = ""
        mediaAlbumName = ""
        shuffle = ""
        entityPicture = ""
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let state = try values.decodeIfPresent(String.self, forKey: .state) {
             self.state = state
         } else {
             self.state = ""
         }

        let attributes = try values.nestedContainer(keyedBy: AttributeKeys.self, forKey: .attributes)

        if let friendlyName = try attributes.decodeIfPresent(String.self, forKey: .friendlyName) {
            self.friendlyName = friendlyName
        } else {
            self.friendlyName = ""
        }

        if let volumeLevel = try attributes.decodeIfPresent(Float.self, forKey: .volumeLevel) {
            self.volumeLevel = volumeLevel
        } else {
            self.volumeLevel = 0
        }

        if let isVolumeMuted = try attributes.decodeIfPresent(Bool.self, forKey: .isVolumeMuted) {
            self.isVolumeMuted = isVolumeMuted
        } else {
            self.isVolumeMuted = false
        }

        if let mediaContentId = try attributes.decodeIfPresent(String.self, forKey: .mediaContentId) {
            self.mediaContentId = mediaContentId
        } else {
            self.mediaContentId = ""
        }

        if let mediaContentType = try attributes.decodeIfPresent(String.self, forKey: .mediaContentType) {
            self.mediaContentType = mediaContentType
        } else {
            self.mediaContentType = ""
        }

        if let mediaDuration = try attributes.decodeIfPresent(Int.self, forKey: .mediaDuration) {
            self.mediaDuration = mediaDuration
        } else {
            self.mediaDuration = 0
        }

        if let mediaPosition = try attributes.decodeIfPresent(Int.self, forKey: .mediaPosition) {
            self.mediaPosition = mediaPosition
        } else {
            self.mediaPosition = 0
        }

        if let mediaPositionUpdatedAt = try attributes.decodeIfPresent(String.self, forKey: .mediaPositionUpdatedAt) {
            self.mediaPositionUpdatedAt = mediaPositionUpdatedAt
        } else {
            self.mediaPositionUpdatedAt = ""
        }

        if let mediaTitle = try attributes.decodeIfPresent(String.self, forKey: .mediaTitle) {
            self.mediaTitle = mediaTitle
        } else {
            self.mediaTitle = ""
        }

        if let mediaArtist = try attributes.decodeIfPresent(String.self, forKey: .mediaArtist) {
            self.mediaArtist = mediaArtist
        } else {
            self.mediaArtist = ""
        }

        if let mediaAlbumName = try attributes.decodeIfPresent(String.self, forKey: .mediaAlbumName) {
            self.mediaAlbumName = mediaAlbumName
        } else {
            self.mediaAlbumName = ""
        }

        if let shuffle = try attributes.decodeIfPresent(String.self, forKey: .shuffle) {
            self.shuffle = shuffle
        } else {
            self.shuffle = ""
        }

        if let entityPicture = try attributes.decodeIfPresent(String.self, forKey: .entityPicture) {
            self.entityPicture = entityPicture
        } else {
            self.entityPicture = ""
        }
    }


    //    "volume_level": 1,
    //    "is_volume_muted": false,
    //    "media_content_id": "spotify://track:6L90mFjGeLu3rsGddZpttR",
    //    "media_content_type": "music",
    //    "media_duration": 304,
    //    "media_position": 99,
    //    "media_position_updated_at": "2020-07-25T15:31:21.272242+00:00",
    //    "media_title": "Your Girl",
    //    "media_artist": "Blue States",
    //    "media_album_name": "Nothing Changes Under The Sun",
    //    "shuffle": "none",
    //    "query_result": {},
    //    "sync_group": [],
    //    "friendly_name": "Transporter",
    //    "entity_picture": "/api/media_player_proxy/media_player.transporter?token=88bea80a6b35d9e83b7910214b7d09a464bceb7a74f9175bb8bfba50722ca59c&cache=4e0bc13a5f1d028c",
    //    "supported_features": 58303
}
