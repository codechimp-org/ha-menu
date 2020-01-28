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
    @IBOutlet weak var textfieldStatus: NSTextField!
    @IBOutlet weak var tableViewGroups: NSTableView!

    @IBAction func buttonCheckConnection(_ sender: NSButton) {
        checkConnection()
    }

    var prefs = Preferences()
    var groups = [String]()
    var menuItems = [PrefMenuItem]()
    private var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")


    override func viewDidLoad() {
        super.viewDidLoad()
        showExistingPrefs()
        checkConnection()

        tableViewGroups.delegate = self
        tableViewGroups.dataSource = self
        tableViewGroups.registerForDraggedTypes([dragDropType])
        tableViewGroups.target = self
        tableViewGroups.doubleAction = #selector(tableViewGroupsDoubleClick(_:))

        tableViewGroups.reloadData()
    }

    override func viewWillDisappear() {
        saveNewPrefs()
        NSApp.stopModal()
        super.viewWillDisappear()
    }

    func checkConnection() {
        saveNewPrefs()
        
        haService.getStates() {
            result in
            switch result {
            case .success( _):
                DispatchQueue.main.async {
                    self.textfieldStatus.stringValue = "OK"
                }

                let groupEntities = self.haService.filterEntities(entityDomain: EntityDomains.groupDomain.rawValue)

                for groupEntity in groupEntities {
                    self.groups.append(groupEntity.friendlyName)
                }

            case .failure(let haServiceApiError):
                DispatchQueue.main.async {
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
        //        buttonLights.state = (prefs.domainLights == true ? .on : .off)
        //        buttonSwitches.state = (prefs.domainSwitches == true ? .on : .off)
        //        buttonAutomations.state = (prefs.domainAutomations == true ? .on : .off)
        //        buttonInputBooleans.state = (prefs.domainInputBooleans == true ? .on : .off)
        //        buttonInputSelects.state = (prefs.domainInputSelects == true ? .on : .off)
        //        textfieldGroup.stringValue = prefs.groupList
        buttonLogin.state = (prefs.launch == true ? .on : .off)

        menuItems = prefs.menuItems
    }

    func saveNewPrefs() {
        prefs.server = textfieldServer.stringValue
        prefs.token = textfieldToken.stringValue
        //        prefs.domainLights = (buttonLights.state == .on)
        //        prefs.domainSwitches = (buttonSwitches.state == .on)
        //        prefs.domainAutomations = (buttonAutomations.state == .on)
        //        prefs.domainInputBooleans = (buttonInputBooleans.state == .on)
        //        prefs.domainInputSelects = (buttonInputSelects.state == .on)
        //        prefs.groupList = textfieldGroup.stringValue
        prefs.launch = (buttonLogin.state == .on)

        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }

    @objc func tableViewGroupsDoubleClick(_ sender:AnyObject) {

        guard tableViewGroups.selectedRow >= 0 else {
            return
        }

        let item = self.menuItems[tableViewGroups.selectedRow]
    }

}

extension PrefsViewController: NSTableViewDelegate, NSTableViewDataSource {

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.menuItems.count
    }

    fileprivate enum TableColumns {
        static let GroupName = NSUserInterfaceItemIdentifier("GroupName")
    }

    private func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> PrefMenuItem? {
        return self.menuItems[row]
    }


    //    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    //
    //        var image: NSImage?
    //        var text: String = ""
    //        var cellIdentifier: NSUserInterfaceItemIdentifier = TableColumns.GroupName
    //
    //
    //        let item = self.menuItems[row]
    //
    //        if tableColumn == tableView.tableColumns[0] {
    //            text = item.entityId
    //            cellIdentifier = TableColumns.GroupName
    //        }
    //
    //        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
    //            cell.state = item.enabled
    //            cell.textField?.stringValue = text
    //            cell.imageView?.image = image ?? nil
    //            return cell
    //        }
    //        return nil
    //    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?
        , row: Int) -> Any? {

        if tableColumn == tableView.tableColumns[0] {
            let cell = tableColumn!.dataCell as! NSButtonCell
            let item = self.menuItems[row]

            cell.state = (item.enabled ? .on : .off)
            cell.title = item.entityId

            return cell
        }

        //        if tableColumn == tableView.tableColumns[1] {
        //            let cell = tableColumn!.dataCell as! NSTextFieldCell
        //            let item = self.menuItems[row]
        //
        ////            let image = NSImage(named: NSImage.Name("InfoImage"))
        //
        //            cell.title = item.entityId
        ////            cell.image = image
        //            return cell
        //        }

        if tableColumn == tableView.tableColumns[1] {
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

        if tableColumn == tableView.tableColumns[1] {
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

        var oldIndexOffset = 0
        var newIndexOffset = 0

        // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
        // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        tableView.endUpdates()

        return true
    }

}
