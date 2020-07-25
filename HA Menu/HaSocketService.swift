//
//  HaSocketService.swift
//  HA Menu
//
//  Created by Andrew Jackson on 25/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation
import Starscream

public protocol HaSocketDelegate: class {
    func socketReady()
}

class HaSocketService: WebSocketDelegate {

    static var shared = HaSocketService()
    private init(){}

    private let multicast = MulticastDelegate<HaSocketDelegate>()
    private var entityIds = [String]()

    var prefs = Preferences()

    var socket: WebSocket?
    var isConnected = false
    var isAuthenticated = false
    var isSubscribedStateChanged = false
    var subscribedStateChangedId = 0
    var id = 0

    func registerMediaPlayer(mediaPlayer: HaSocketDelegate, entityId: String) {
        multicast.add(delegate: mediaPlayer)
        entityIds.append(entityId)

        if isConnected {
            if isAuthenticated {
                if entityIds.count > 0 {
                    if !isSubscribedStateChanged {
                        subscribeStateChanged()
                    }
                }
            }
        }
    }

    func unregisterMediaPlayer(mediaPlayer: HaSocketDelegate, entityId: String) {
        multicast.remove(delegate: mediaPlayer)
        entityIds.removeAll(where: { $0 == entityId })

        if multicast.count == 0 {
            unsubscribeStateChanged()
        }
    }

    //MARK: WebSocketDelegates
    func connect() {
        let request = URLRequest(url: URL(string: prefs.serverWebSocket)!)
        let pinner = FoundationSecurity(allowSelfSigned: true)

        socket = WebSocket(request: request, certPinner: pinner)
        socket!.delegate = self
        socket!.connect()
    }

    func disconnect() {
        unsubscribeStateChanged()
        socket?.disconnect()
        print("Socket disconnected")
    }

    func sendMessage(message: String) {
        socket?.write(string: message)
    }

    func subscribeStateChanged() {
        id += 1
        subscribedStateChangedId = id
        let subscribe = HaSocketMessageSubscribeEvents(id: id, eventType: "state_changed")
        if let subscribeJson = subscribe.jsonString {
            socket?.write(string: subscribeJson)

            isSubscribedStateChanged = true
            print("Subscribed State Change \(subscribedStateChangedId)")
        }
    }

    func unsubscribeStateChanged() {
        if isSubscribedStateChanged {
            id += 1
            let unsubscribe = HaSocketMessageUnsubscribeEvents(id: id, subscriptionId: subscribedStateChangedId)
            if let unsubscribeJson = unsubscribe.jsonString {
                socket?.write(string: unsubscribeJson)

                print("Unsubscribed State Change \(subscribedStateChangedId)")
                isSubscribedStateChanged = false
            }
        }
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")

            guard let data = string.data(using: .utf16) else {
                return
            }

            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                    if let type = json["type"] as? String {
                        switch type {

                        case HaSocketMessageTypes.authRequired.rawValue:
                            let auth = HaSocketMessageAuth(accessToken: prefs.token)
                            if let authJson = auth.jsonString {
                                socket?.write(string: authJson)
                            }

                        case HaSocketMessageTypes.authOk.rawValue:
                            isAuthenticated = true
                            multicast.invoke(invocation: { $0.socketReady() })

                            if entityIds.count > 0 {
                                if !isSubscribedStateChanged {
                                    subscribeStateChanged()
                                }
                            }

                        case HaSocketMessageTypes.authInvalid.rawValue:
                            isAuthenticated = false

                        case HaSocketMessageTypes.result.rawValue:
                            let result = try JSONDecoder().decode(HaSocketMessageResult.self, from: data)
                            print(result.id)

                        default:
                            print("Unknown message type \(type)")
                        }
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }

//            do {
//                let decodedResponse = try JSONDecoder().decode(HaSocketMessage.self, from: data)
//
//                print(decodedResponse.type.rawValue)
//
//            }
//            catch {
//                // Fail to decode
//            }




        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print(error.debugDescription)

        }
    }

}
