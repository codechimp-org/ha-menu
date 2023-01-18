//
//  Server.swift
//  HA Menu
//
//  Created by Andrew Jackson on 18/01/2023.
//

import Foundation

struct HaServerDetails: Codable, Identifiable {
    var id = UUID()
    @Trimmed var friendlyName: String = ""
    @Trimmed var serverUrl: String = ""
    @Trimmed var serverToken: String = ""
    var enabled: Bool = true
    
    func authURLRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(serverToken)", forHTTPHeaderField: "Authorization")

        return request
    }
}
