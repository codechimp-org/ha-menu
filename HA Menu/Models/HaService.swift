//
//  ServerState.swift
//  HA Menu
//
//  Created by Andrew Jackson on 18/01/2023.
//

import Foundation

class HaService {
    
    var haServerDetails: HaServerDetails
    var haStates: [HaState] = []
    
    init(haServerDetails: HaServerDetails) {
        self.haServerDetails = haServerDetails
    }
    
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
    
    func getStates(completionHandler: @escaping (Result<Bool, HaServiceApiError>) -> Void) {
        
        if (haServerDetails.serverUrl.count == 0 ) {
            completionHandler(.failure(.URLMissing))
            return
        }
        
        guard let url = URL(string: "\(haServerDetails.serverUrl)/api/states") else {
            completionHandler(.failure(.InvalidURL))
            return
        }
        
        var request = haServerDetails.authURLRequest(url: url)
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
         let url = URL(string: "\(haServerDetails.serverUrl)/api/services/\(haEntity.domain)/toggle")
         var request = haServerDetails.authURLRequest(url: url!)
         
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
         
         let url = URL(string: "\(haServerDetails.serverUrl)/api/services/input_select/select_option")
         var request = haServerDetails.authURLRequest(url: url!)
         
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
         let url = URL(string: "\(haServerDetails.serverUrl)/api/services/\(haEntity.domain)/turn_on")
         var request = haServerDetails.authURLRequest(url: url!)
         
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
         let url = URL(string: "\(haServerDetails.serverUrl)/api/services/\(haEntity.domain)/press")
         var request = haServerDetails.authURLRequest(url: url!)
         
         request.httpMethod = "POST"
         request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

         let session = URLSession.shared
         let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
             print(String(data: data!, encoding: String.Encoding.utf8)!)
         })

         task.resume()
     }

     
 }

