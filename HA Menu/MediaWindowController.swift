//
//  MediaWindowController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 21/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Cocoa

class MediaWindowController: NSWindowController, NSWindowDelegate {

    @IBOutlet var mediaWindow: NSWindow!

    var haService = HaService.shared

    var haEntity: HaEntity? {
        didSet {
            mediaWindow.title = "\(haEntity?.friendlyName ?? "Unknown media player entity")"
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        mediaWindow.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        MediaWindowStack.shared.closeWindow(haEntity: haEntity!)
    }

    func windowDidBecomeMain(_ notification: Notification) {

    }


}
