//
//  ShortcutTextFieldCell.swift
//  HA Menu
//
//  Created by Andrew Jackson on 06/03/2021.
//  Copyright © 2021 CodeChimp. All rights reserved.
//

import Cocoa
//import Carbon.HIToolbox

private final class ShortcutTextFieldCellTextView: NSTextView, NSTextViewDelegate {
    override func keyDown(with event: NSEvent) {
        
        var globalKeybind: GlobalKeybindPreferences?
        
        let textView = window?.firstResponder as? NSTextView
        
        if let characters = event.charactersIgnoringModifiers {
            let globalKeybind = GlobalKeybindPreferences.init(
                function: event.modifierFlags.contains(.function),
                control: event.modifierFlags.contains(.control),
                command: event.modifierFlags.contains(.command),
                shift: event.modifierFlags.contains(.shift),
                option: event.modifierFlags.contains(.option),
                capsLock: event.modifierFlags.contains(.capsLock),
                carbonFlags: 0,
                characters: characters,
                keyCode: UInt32(event.keyCode)
            )
            
            textView?.string = globalKeybind.description
            return
        }
                
        super.keyDown(with: event)
    }
    
    override func insertNewline(_ sender: Any?) {
        window?.makeFirstResponder(nextResponder)
    }
    
    var originalText: String?
    override func cancelOperation(_ sender: Any?) {
        if let o = originalText {
            self.string = o
        }
        window?.makeFirstResponder(nextResponder)
    }
    
    override func viewDidMoveToSuperview() {
        if superview != nil {
            originalText = textContainer?.textView?.string
        }
    }
}

final class ShortcutTextFieldCell: NSTextFieldCell {
    private lazy var stfctv: ShortcutTextFieldCellTextView = {
        return ShortcutTextFieldCellTextView()
    }()
    override func fieldEditor(for controlView: NSView) -> NSTextView? {
        return stfctv
    }
}
