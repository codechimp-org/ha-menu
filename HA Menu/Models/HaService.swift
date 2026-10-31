//
//  HaService.swift
//  HA Menu
//
//  Created by Andrew Jackson on 26/01/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation

class HaService {

    static var shared = HaService()
    private init() {}

    enum HaServiceApiError: LocalizedError {
        case URLMissing
        case InvalidURL
        case Unauthorized
        case NotFound
        case UnknownResponse
        case JSONDecodeError
        case UnknownError(message: String)
    }

    enum HaServiceEntityError: Error {
        case EntityNotFound
    }

    var haStates: [HaState] = []

    var prefs = Preferences()

    /// Builds an endpoint URL from the configured server value.
    /// Accepts http/https hosts with optional port and optional trailing
    /// slash(es); trims pasted whitespace/newlines, drops invisible pasted
    /// characters (zero-width spaces, BOM, control chars) that look clean in
    /// the Server field yet break URL parsing, strips trailing slashes so no
    /// `//api/...` double-slash is produced, and assumes http when the user
    /// omits the scheme (e.g. `192.168.1.4:8123`). Returns nil for truly bad
    /// input (empty, unparseable, non-http(s) scheme, missing host).
    func apiURL(path: String) -> URL? {
        // Invisible characters that survive whitespace trimming but make
        // URLComponents fail (or produce a wrong host) while the Server
        // field looks exactly like a valid URL.
        let invisible = CharacterSet(charactersIn: "\u{200B}\u{200C}\u{200D}\u{FEFF}")
            .union(.controlCharacters)
        var base = prefs.server.components(separatedBy: invisible).joined()
        base = base.trimmingCharacters(in: .whitespacesAndNewlines)
        if base.isEmpty {
            return nil
        }
        if !base.contains("://") {
            base = "http://" + base
        }
        guard var components = URLComponents(string: base),
            let scheme = components.scheme?.lowercased(),
            scheme == "http" || scheme == "https",
            let host = components.host, !host.isEmpty else {
            return nil
        }
        var basePath = components.path
        while basePath.hasSuffix("/") {
            basePath = String(basePath.dropLast())
        }
        components.path = basePath + path
        return components.url
    }

    func createAuthURLRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(prefs.token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func getStates(completionHandler: @escaping (Result<Bool, HaServiceApiError>) -> Void)  {

        if (prefs.server.count == 0 ) {
            completionHandler(.failure(.URLMissing))
            return
        }

        guard let url = apiURL(path: "/api/states") else {
            completionHandler(.failure(.InvalidURL))
            return
        }

        var request = createAuthURLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) {data, response, error in

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    switch httpResponse.statusCode {
                    case 401:
                        completionHandler(.failure(.Unauthorized))
                    case 404:
                        completionHandler(.failure(.NotFound))
                    default:
                        completionHandler(.failure(.UnknownResponse))
                    }
                    return
                }
            }

            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([HaState].self, from: data)
                    self.haStates = decodedResponse

                    completionHandler(.success(true))

                } catch {
                    completionHandler(.failure(.JSONDecodeError))
                }
                return
            }
            completionHandler(.failure(.UnknownError(message: error?.localizedDescription ?? "")))

        }.resume()
    }

    func getState(entityId: String, completionHandler: @escaping (Result<HaState, HaServiceEntityError>) -> Void) {

        guard let entity = haStates.first(where: {$0.entityId == entityId}) else {
            completionHandler(.failure(.EntityNotFound))
            return
        }

        completionHandler(.success(entity))
    }

    func filterEntities(entityDomain: String) -> [HaEntity] {
        var entities = [HaEntity]()

        for haState in haStates {
            if (haState.entityId.starts(with: entityDomain + ".")) {
                // Do not add unavailable state entities
                if (haState.state != "unavailable") {

                    let haEntity: HaEntity = HaEntity(entityId: haState.entityId, friendlyName: (haState.attributes.friendlyName), state: (haState.state), unitOfMeasurement: haState.attributes.unitOfMeasurement, options: haState.attributes.options)

                    entities.append(haEntity)
                }
            }
        }

        entities = entities.sorted(by: {$0.friendlyName > $1.friendlyName})

        return entities
    }

    func toggleEntityState(haEntity: HaEntity) {
        let params = ["entity_id": haEntity.entityId]

        guard let url = apiURL(path: "/api/services/\(haEntity.domain)/toggle") else {
            return
        }
        var request = createAuthURLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    func selectInputSelectOption(haEntity: HaEntity, option: String) {
        let params = ["entity_id": haEntity.entityId, "option": option]

        guard let url = apiURL(path: "/api/services/input_select/select_option") else {
            return
        }
        var request = createAuthURLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    func turnOnEntity(haEntity: HaEntity) {
        let params = ["entity_id": haEntity.entityId]

        guard let url = apiURL(path: "/api/services/\(haEntity.domain)/turn_on") else {
            return
        }
        var request = createAuthURLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }
    
    func pressEntity(haEntity: HaEntity) {
        let params = ["entity_id": haEntity.entityId]

        guard let url = apiURL(path: "/api/services/\(haEntity.domain)/press") else {
            return
        }
        var request = createAuthURLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    
}
