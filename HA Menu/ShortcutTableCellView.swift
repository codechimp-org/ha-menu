//
//  ShortcutTableCellView.swift
//  HA Menu
//
//  Created by Andrew Jackson on 07/03/2021.
//  Copyright © 2021 CodeChimp. All rights reserved.
//

import Cocoa
import MASShortcut

class ShortcutTableCellView: NSTableCellView {

    @IBOutlet weak var shortcutView: MASShortcutView!

    func configure(_ name: String,
                   icon: NSImage?,
                   shortcut: MASShortcut?,
                   shortcutValueChange: @escaping (MASShortcut?) -> Void) {
        textField?.stringValue = name
        imageView?.image = icon

        shortcutView.shortcutValueChange = nil
        shortcutView.shortcutValue = shortcut
        shortcutView.shortcutValueChange = { sender in
            shortcutValueChange(sender.shortcutValue)
        }
    }

}
