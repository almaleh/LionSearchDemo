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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullNameLabel.stringValue = user.fullName
        groupNumberLabel.stringValue = "is a member of \(user.groups.count) AD groups:"
//        self.preferredContentSize = view.frame.size
//        self.view.autoresizesSubviews = false
//        self.view.window?.styleMask.remove(NSWindow.StyleMask.resizable)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        view.window!.styleMask.remove(NSWindow.StyleMask.resizable)
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return user.groups.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        text = user.groups[row]
        let ADCell = NSUserInterfaceItemIdentifier("ADGroupCell")
        if let cell = tableView.makeView(withIdentifier: ADCell, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    @IBAction func clipBtn(_ sender: Any) {
        
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
