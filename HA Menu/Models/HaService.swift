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

        guard let url = URL(string: "\(prefs.server)/api/states") else {
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

                    let haEntity: HaEntity = HaEntity(entityId: haState.entityId, friendlyName: (haState.attributes.friendlyName), state: (haState.state), options: haState.attributes.options)

                    entities.append(haEntity)
                }
            }
        }

        entities = entities.sorted(by: {$0.friendlyName > $1.friendlyName})

        return entities
    }

    func toggleEntityState(haEntity: HaEntity) {
        let params = ["entity_id": haEntity.entityId]
        let urlString = "\(prefs.server)/api/services/\(haEntity.domain)/toggle"

        var request = createAuthURLRequest(url: URL(string: urlString)!)

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

        var request = createAuthURLRequest(url: URL(string: "\(prefs.server)/api/services/input_select/select_option")!)

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
        let urlString = "\(prefs.server)/api/services/\(haEntity.domain)/turn_on"

        var request = createAuthURLRequest(url: URL(string: urlString)!)

        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(String(data: data!, encoding: String.Encoding.utf8)!)
        })

        task.resume()
    }

    
}
