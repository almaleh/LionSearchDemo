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
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullNameLabel.stringValue = user.fullName
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        // Do view setup here.
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        
        text = "Smarm"
        let ADCell = NSUserInterfaceItemIdentifier("ADGroupCell")
        if let cell = tableView.makeView(withIdentifier: ADCell, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
