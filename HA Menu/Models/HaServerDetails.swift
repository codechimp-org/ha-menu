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
    @SanitizedUrl var serverUrl: String = ""
    @Trimmed var serverToken: String = ""
    var enabled: Bool = true
    
    func authURLRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(serverToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    @propertyWrapper
    struct Trimmed: Codable {
        private(set) var value: String = ""
        
        var wrappedValue: String {
            get { value }
            set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        
        init(wrappedValue initialValue: String) {
            self.wrappedValue = initialValue
        }
    }
    
    @propertyWrapper
    struct SanitizedUrl: Codable {
        private(set) var value: String = ""
        
        var wrappedValue: String {
            get { value }
            set {
                value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remove trailing slash
                if (value.hasSuffix("/")) {
                    value = String(value.dropLast())
                }
            }
        }
        
        init(wrappedValue initialValue: String) {
            self.wrappedValue = initialValue
        }
    }
    
}
