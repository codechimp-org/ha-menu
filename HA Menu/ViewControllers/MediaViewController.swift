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

    var imageLoaded = false

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

    func mediaStateChanged(event: HaEvent) {
        if event.entityId == haEntity?.entityId {
            labelTest.stringValue = "\(event.newState.mediaArtist) - \(event.newState.mediaTitle) - \(event.newState.state)"


            if !imageLoaded || event.isImageChanged {
                guard let url = URL(string: prefs.server + event.newState.entityPicture) else {
                    return
                }

                print("Image Load: \(url)")
                imageArt.load(url: url)
                imageLoaded = true
            }
        }

    }

    //MARK: Properties

    @IBOutlet weak var labelTest: NSTextField!
    @IBOutlet weak var imageArt: NSImageView!

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

extension NSImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = NSImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


