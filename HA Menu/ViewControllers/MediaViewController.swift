//
//  MediaViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 22/07/2020.
//  Copyright © 2020 CodeChimp. All rights reserved.
//

import Cocoa

class MediaViewController: NSViewController {



    var haRestService = HaRestService.shared
    var haSocketService = HaSocketService.shared

    var prefs = Preferences()

    var haEntity: HaEntity? {
        didSet {
            // TODO: init socket

            labelTest.stringValue = haEntity!.friendlyName


        }
    }

    //MARK: Properties

    @IBOutlet weak var labelTest: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        haSocketService.connect()

    }

    override func viewWillDisappear() {

        haSocketService.disconnect()
        
        super.viewWillDisappear()
    }


}
