//
//  ShortcutsViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 01/03/2021.
//  Copyright © 2021 CodeChimp. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox
import MASShortcut

class ShortcutsViewController: NSViewController {
    
    @IBOutlet weak var tableViewShortcuts: NSTableView!
    @IBOutlet weak var segementedControlShortcuts: NSSegmentedControl!
    
    @IBAction func segementedControlShortcutsPressed(_ sender: NSSegmentedCell) {
        switch segementedControlShortcuts.selectedSegment {
        case 0:
            let newShortcut = GlobalKeybindPreferences.init(
                function: false,
                control: false,
                command: true,
                shift: true,
                option: true,
                capsLock: false,
                carbonFlags: 0,
                characters: "H",
                keyCode: 0
            )
            shortcuts.append(PrefGlobalShortcut(entityId: "switch.test", shortcut: newShortcut))
            tableViewShortcuts.beginUpdates()
            tableViewShortcuts.insertRows(at: IndexSet(integer: self.shortcuts.count - 1), withAnimation: .effectFade)
            tableViewShortcuts.endUpdates()
            
        case 1:
            removeSelectedRows()
        default: break;
        }
    }
    
    private var prefs = Preferences()
    public var shortcuts = [PrefGlobalShortcut]()
    private var itemSelected: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shortcuts = prefs.globalShortcuts
        
        tableViewShortcuts.delegate = self
        tableViewShortcuts.dataSource = self
        tableViewShortcuts.target = self
        
        setRemoveButtonState()
    }
    
    override func viewWillDisappear() {
        prefs.globalShortcuts = self.shortcuts
        super.viewWillDisappear()
    }
    
    private func setRemoveButtonState() {
        self.segementedControlShortcuts.setEnabled(itemSelected >= 0, forSegment: 1)
    }
}

extension ShortcutsViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.shortcuts.count
    }
    
    private func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> PrefGlobalShortcut? {
        return self.shortcuts[row]
    }
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?
                   , row: Int) -> Any? {
        
        if tableColumn == tableView.tableColumns[0] {
            let item = self.shortcuts[row]
            return item.entityId
        }
        
        if tableColumn == tableView.tableColumns[1] {
            let item = self.shortcuts[row]
            return item.shortcut.description
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        itemSelected = tableViewShortcuts.selectedRow
        
        setRemoveButtonState()
    }
    
    func removeSelectedRows() {
        guard itemSelected >= 0 else { return }
        
        self.shortcuts.remove(at: itemSelected)
        tableViewShortcuts.beginUpdates()
        tableViewShortcuts.removeRows(at: tableViewShortcuts.selectedRowIndexes, withAnimation: .effectFade)
        tableViewShortcuts.endUpdates()
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
        if tableColumn == tableView.tableColumns[0] {
            self.shortcuts[row].entityId = object as! String
        }
        
        if tableColumn == tableView.tableColumns[1] {
            // This is where I need to use my object
            self.shortcuts[row].shortcut = object as! GlobalKeybindPreferences
        }
    }
    
}
