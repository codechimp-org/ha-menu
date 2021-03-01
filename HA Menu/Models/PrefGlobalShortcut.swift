//
//  PrefGlobalShortcut.swift
//  HA Menu
//
//  Created by Andrew Jackson on 27/02/2021.
//  Copyright © 2021 CodeChimp. All rights reserved.
//

import Foundation

struct PrefGlobalShortcut: Codable {
    var entityId: String
    var shortcut: GlobalKeybindPreferences

    private enum CodingKeys: String, CodingKey {
        case entityId, shortcut
    }
}
