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

    private init() {}

    func createWindow(haEntity: HaEntity) {
        var mediaWindowController: MediaWindowController? = nil

            let mainStoryBoard = NSStoryboard(name: "Main", bundle: nil)
            if let windowController = mainStoryBoard.instantiateController(withIdentifier: "MediaWindowController") as? NSWindowController {
                mediaWindowController = windowController as? MediaWindowController

                mediaWindowController?.haEntity = haEntity
                windows[haEntity.entityId] = mediaWindowController!
    //        let settingsController = windowController.window!.contentViewController as! SettingsController

                // make initial settings before showing the window
                mediaWindowController!.showWindow(self)

                if NSApp.activationPolicy() == .accessory {
                    NSApp.setActivationPolicy(.regular)
                }
            }
    }

    func closeWindow(haEntity: HaEntity) {

        windows.removeValue(forKey: haEntity.entityId)

        if windows.count == 0 {
            NSApp.setActivationPolicy(.accessory)
        }
    }


}
