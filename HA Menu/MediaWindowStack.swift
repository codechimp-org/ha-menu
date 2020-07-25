//
//  MediaWindowStack.swift
//  HA Menu
//
//  Created by Andrew Jackson on 22/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Foundation
import Cocoa

class MediaWindowStack {

    static var shared = MediaWindowStack()
    public var windows = [String: MediaWindowController]()

    var haSocketService = HaSocketService.shared

    private init() {}

    func createWindow(haEntity: HaEntity) {

        if windows.count == 0 {
            haSocketService.connect()
        }

        if windows.keys.contains(haEntity.entityId) {
            windows[haEntity.entityId]?.showWindow(self)
        }
        else {
            var mediaWindowController: MediaWindowController? = nil

            let mainStoryBoard = NSStoryboard(name: "Main", bundle: nil)
            if let windowController = mainStoryBoard.instantiateController(withIdentifier: "MediaWindowController") as? NSWindowController {
                mediaWindowController = windowController as? MediaWindowController

                mediaWindowController?.haEntity = haEntity
                windows[haEntity.entityId] = mediaWindowController!

                let mediaViewController = windowController.window!.contentViewController as! MediaViewController

                // make initial settings before showing the window
                mediaViewController.haEntity = haEntity

                mediaWindowController!.haEntity = haEntity

                mediaWindowController!.showWindow(self)

                if NSApp.activationPolicy() == .accessory {
                    NSApp.setActivationPolicy(.regular)
                }
            }
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow(haEntity: HaEntity) {

        windows.removeValue(forKey: haEntity.entityId)

        if windows.count == 0 {

            haSocketService.unsubscribeStateChanged()

            haSocketService.disconnect()

            NSApp.setActivationPolicy(.accessory)
        }
    }


}
