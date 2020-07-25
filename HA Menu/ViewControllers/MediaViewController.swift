//
//  MediaViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 22/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Cocoa
import Starscream

class MediaViewController: NSViewController, WebSocketDelegate {



    var haRestService = HaRestService.shared
    var prefs = Preferences()

    var socket: WebSocket?
    var isConnected = false

    var haEntity: HaEntity? {
        didSet {
            // TODO: init socket

            labelTest.stringValue = haEntity!.friendlyName

            var request = URLRequest(url: URL(string: prefs.serverWebSocket)!)
            let pinner = FoundationSecurity(allowSelfSigned: true)

            request.timeoutInterval = 5
            socket = WebSocket(request: request, certPinner: pinner)
            socket!.delegate = self
            socket!.connect()

        }
    }

    //MARK: Properties

    @IBOutlet weak var labelTest: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillDisappear() {


        super.viewWillDisappear()
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
