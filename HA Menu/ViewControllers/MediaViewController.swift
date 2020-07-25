//
//  MediaViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 22/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Cocoa

class MediaViewController: NSViewController, HaSocketDelegate {

    var haRestService = HaRestService.shared
    var haSocketService = HaSocketService.shared

    var prefs = Preferences()

    var haEntity: HaEntity? {
        didSet {
            // TODO: init socket

            labelTest.stringValue = haEntity!.friendlyName

            haSocketService.registerMediaPlayer(mediaPlayer: self, entityId: haEntity!.entityId)
        }
    }

    //MARK: HaSocketDelegate
    func socketReady() {
        print("Socket ready at player")
    }

    //MARK: Properties

    @IBOutlet weak var labelTest: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear() {
        haSocketService.unregisterMediaPlayer(mediaPlayer: self, entityId: haEntity!.entityId)

        super.viewWillDisappear()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        // Set always on top
//        view.window?.level = .floating
    }


}
