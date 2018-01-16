//
//  SheetViewController.swift
//  Lion Search
//
//  Created by Besher on 2017-10-30.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Cocoa

class SheetViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    
    @IBOutlet weak var fullNameLabel: NSTextField!
    @IBOutlet weak var groupNumberLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var filterLabel: NSSearchField!
    var filteredGroups = [String]()
    var userData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = userData else { return }
        fullNameLabel.stringValue = user.fullName
        groupNumberLabel.stringValue = "is a member of \(user.groups.count) AD groups:"
        filteredGroups = user.groups
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func viewDidAppear() {
        view.window!.styleMask.remove(NSWindow.StyleMask.resizable)
    }
    
    @IBAction func filterGroups(_ sender: Any) {
        guard let user = userData else { return }
        if !filterLabel.stringValue.isEmpty {
            var newFiltered = [String]()
            for group in user.groups {
                if group.lowercased().contains(filterLabel.stringValue.lowercased()) {
                    newFiltered.append(group)
                }
            }
            filteredGroups = newFiltered
            tableView.reloadData()
        } else {
            filteredGroups = user.groups
            tableView.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredGroups.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        text = filteredGroups[row]
        let ADCell = NSUserInterfaceItemIdentifier("ADGroupCell")
        if let cell = tableView.makeView(withIdentifier: ADCell, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    @IBAction func clipBtn(_ sender: Any) {
        guard let user = userData else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        var pasteboardString = "Report generated on: " + user.todaysDate + "\nUsername: " + user.username + "\nFull name: " + user.fullName + "\nJob title: " + user.jobTitle + "\nMember of the following AD groups:\n\n"
        for group in user.groups {
            pasteboardString += group
            pasteboardString += "\n"
        }
        pasteboard.setString(pasteboardString, forType: NSPasteboard.PasteboardType.string)
    }
    
}
