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

        fileSleepNotifications()

        if let haEntity = haEntity {
            haSocketService.registerMediaPlayer(mediaPlayer: self, entityId: haEntity.entityId)
        }

        // Set always on top
//        view.window?.level = .floating
    }


    @objc func onWakeNote(note: NSNotification) {
        if let haEntity = haEntity {
             haSocketService.registerMediaPlayer(mediaPlayer: self, entityId: haEntity.entityId)
         }
    }

    @objc func onSleepNote(note: NSNotification) {
        haSocketService.unregisterMediaPlayer(mediaPlayer: self, entityId: haEntity!.entityId)
    }

    func fileSleepNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onWakeNote(note:)),
            name: NSWorkspace.didWakeNotification, object: nil)

        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onSleepNote(note:)),
            name: NSWorkspace.willSleepNotification, object: nil)
    }

}
