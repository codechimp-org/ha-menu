//
//  PrefsViewController.swift
//  HA Menu
//
//  Created by Andrew Jackson on 04/11/2018.
//  Copyright © 2018 CodeChimp. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {

    var haService = HaService.shared

    @IBOutlet weak var textfieldServer: NSTextField!
    @IBOutlet weak var textfieldToken: NSTextField!
    @IBOutlet weak var buttonLogin: NSButton!
    @IBOutlet weak var buttonBetaNotifications: NSButton!
    @IBOutlet weak var textfieldStatus: NSTextField!
    @IBOutlet weak var tableViewGroups: NSTableView!
    @IBOutlet weak var segementedControlShortcuts: NSSegmentedControl!
    @IBOutlet weak var tableViewShortcuts: NSTableView!
    
    @IBAction func buttonCheckConnection(_ sender: NSButton) {
        connect()
    }

    @IBAction func segementedControlShortcutsPressed(_ sender: NSSegmentedControl) {
        
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
            shortcutsTable.shortcuts.append(PrefGlobalShortcut(entityId: "switch.test", shortcut: newShortcut))
            tableViewShortcuts.beginUpdates()
            tableViewShortcuts.insertRows(at: IndexSet(integer: shortcutsTable.shortcuts.count - 1), withAnimation: .effectFade)
            tableViewShortcuts.endUpdates()

        case 1:
            shortcutsTable.removeSelectedRows()
        default: break;
        }
    }
    
    var prefs = Preferences()
    var groups = [HaEntity]()
    var okToSaveMenuItems = false
    var groupsTable = GroupsTable()
    var shortcutsTable = ShortcutsTable()


    override func viewDidLoad() {
        super.viewDidLoad()
        showExistingPrefs()

        tableViewGroups.delegate = groupsTable
        tableViewGroups.dataSource = groupsTable
        tableViewGroups.registerForDraggedTypes([groupsTable.dragDropType])
        tableViewGroups.target = groupsTable

        tableViewShortcuts.delegate = shortcutsTable
        tableViewShortcuts.dataSource = shortcutsTable
        tableViewShortcuts.target = shortcutsTable
        
        connect()
    }

    override func viewWillDisappear() {
        saveNewPrefs()
        saveNewMenuItems()
        NSApp.stopModal()
        super.viewWillDisappear()
    }

    func connect() {
        saveNewPrefs()

        groupsTable.menuItems.removeAll()
        
        haService.getStates() {
            result in
            switch result {
            case .success( _):
                DispatchQueue.main.async {
                    self.okToSaveMenuItems = true
                    self.textfieldStatus.stringValue = "Connected"

                    self.groups = self.haService.filterEntities(entityDomain: EntityDomains.groupDomain.rawValue).reversed()

                    let menuItemsWithFriendlyNames = self.prefs.menuItemsWithFriendlyNames(groups: self.groups)

                    let sortedMenuItemsWithFriendlyNames = menuItemsWithFriendlyNames.sorted { $0.value.index < $1.value.index }

                    for (_, value) in sortedMenuItemsWithFriendlyNames {
                        self.groupsTable.menuItems.append(value)
                    }

                    self.tableViewGroups.reloadData()
                }

            case .failure(let haServiceApiError):
                DispatchQueue.main.async {
                    self.okToSaveMenuItems = false

                    self.groupsTable.menuItems.removeAll()
                    self.tableViewGroups.reloadData()

                    switch haServiceApiError {
                    case .URLMissing:
                        self.textfieldStatus.stringValue = "Server URL missing"
                    case .InvalidURL:
                        self.textfieldStatus.stringValue = "Invalid URL"
                    case .Unauthorized:
                        self.textfieldStatus.stringValue = "Unauthorized"
                    case .NotFound:
                        self.textfieldStatus.stringValue = "Not Found"
                    case .UnknownResponse:
                        self.textfieldStatus.stringValue = "Unknown Response"
                    case .JSONDecodeError:
                        self.textfieldStatus.stringValue = "Error Decoding JSON"
                    case .UnknownError:
                        print(haServiceApiError.localizedDescription)
                        self.textfieldStatus.stringValue = "Unknown Error (check your server/port)"
                    }
                }
            }
        }
    }

    func showExistingPrefs() {
        textfieldServer.stringValue = prefs.server
        textfieldToken.stringValue = prefs.token
        buttonBetaNotifications.state = (prefs.betaNotifications == true ? .on : .off)
        buttonLogin.state = (prefs.launch == true ? .on : .off)
        shortcutsTable.shortcuts = prefs.globalShortcuts
    }

    func saveNewPrefs() {
        prefs.server = textfieldServer.stringValue
        prefs.token = textfieldToken.stringValue
        prefs.betaNotifications = (buttonBetaNotifications.state == .on)
        prefs.launch = (buttonLogin.state == .on)
        prefs.globalShortcuts = shortcutsTable.shortcuts

        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }

    func saveNewMenuItems() {
        if okToSaveMenuItems {
            prefs.menuItems = groupsTable.menuItems
        }
    }
    
}

class GroupsTable: NSTableView, NSTableViewDelegate, NSTableViewDataSource {
    
    public var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    
    public var menuItems = [PrefMenuItem]()

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.menuItems.count
    }

    private func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> PrefMenuItem? {
        return self.menuItems[row]
    }

    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?
        , row: Int) -> Any? {

        if tableColumn == tableView.tableColumns[0] {
            let cell = tableColumn!.dataCell as! NSButtonCell
            let item = self.menuItems[row]

            cell.state = (item.enabled ? .on : .off)
            return cell
        }

        if tableColumn == tableView.tableColumns[1] {
            let item = self.menuItems[row]
            return item.friendlyName
        }

        if tableColumn == tableView.tableColumns[2] {
            let cell = tableColumn!.dataCell as! NSButtonCell
            let item = self.menuItems[row]

            cell.state = (item.subMenu ? .on : .off)
            return cell
        }

        return nil
    }


    func tableView(_ tableView: NSTableView, setObjectValue object: Any?
        , for tableColumn: NSTableColumn?, row: Int) {

        if tableColumn == tableView.tableColumns[0] {
            if (object! as AnyObject).intValue == 1 {
                self.menuItems[row].enabled = true
            } else {
                self.menuItems[row].enabled = false
            }
        }

        if tableColumn == tableView.tableColumns[2] {
            if (object! as AnyObject).intValue == 1 {
                self.menuItems[row].subMenu = true
            } else {
                self.menuItems[row].subMenu = false
            }
        }
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {

        let item = NSPasteboardItem()
        item.setString(String(row), forType: self.dragDropType)
        return item
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {

        if dropOperation == .above {
            return .move
        }
        return []
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {

        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
            if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }


        let oldIndex = oldIndexes[0]
        let element = menuItems.remove(at: oldIndexes[0])

        if oldIndex < row {
            self.menuItems.insert(element, at: row - 1)
        }
        else {
            self.menuItems.insert(element, at: row)
        }

        tableView.reloadData()
        return true
    }

}

class ShortcutsTable: NSTableView, NSTableViewDelegate, NSTableViewDataSource {
        
    public var shortcuts = [PrefGlobalShortcut]()
    private var itemSelected: Int = -1
    
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
        let selected = selectedRowIndexes.map { Int($0) }
        print(selected)
    }
    
    func removeSelectedRows() {
        let toDelete = self.clickedRow
        print(toDelete)
        
        if self.selectedRowIndexes.count > 0 {
            self.selectedRowIndexes.forEach { row in
                print(row)
            }
//            self.shortcuts.remove(at: itemSelected)
            beginUpdates()
            removeRows(at: self.selectedRowIndexes, withAnimation: .effectFade)
            endUpdates()
        }

        
//        if let itemsSelected = itemsSelected {
//            itemsSelected.forEach { (i) in
//                self.shortcuts.remove(at: i)
//            }
//            beginUpdates()
//            removeRows(at: itemsSelected, withAnimation: .effectFade)
//            endUpdates()
//        }
        
    }


//    func tableView(_ tableView: NSTableView, setObjectValue object: Any?
//        , for tableColumn: NSTableColumn?, row: Int) {
//
//        if tableColumn == tableView.tableColumns[0] {
//            if (object! as AnyObject).intValue == 1 {
//                self.shortcuts[row].enabled = true
//            } else {
//                self.shortcuts[row].enabled = false
//            }
//        }
//
//        if tableColumn == tableView.tableColumns[2] {
//            if (object! as AnyObject).intValue == 1 {
//                self.shortcuts[row].subMenu = true
//            } else {
//                self.shortcuts[row].subMenu = false
//            }
//        }
//    }

}
