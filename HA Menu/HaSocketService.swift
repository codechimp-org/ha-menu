//
//  HaSocketService.swift
//  HA Menu
//
//  Created by Andrew Jackson on 25/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation
import Starscream

class HaSocketService: WebSocketDelegate {

    static var shared = HaSocketService()
    private init(){}

    var prefs = Preferences()

    var socket: WebSocket?
    var isConnected = false

    func connect() {
        var request = URLRequest(url: URL(string: prefs.serverWebSocket)!)
        let pinner = FoundationSecurity(allowSelfSigned: true)

        //        request.timeoutInterval = 5
        socket = WebSocket(request: request, certPinner: pinner)
        socket!.delegate = self
        socket!.connect()

    }

    func disconnect() {
        socket?.disconnect()
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

            // Parse result
            //            {"type": "auth_required", "ha_version": "0.113.0"}

            guard let data = string.data(using: .utf16) else {
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(HaSocketMessage.self, from: data)

                print(decodedResponse.type.rawValue)

            }
            catch {
                // Fail to decode
            }




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
