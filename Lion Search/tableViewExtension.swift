//
//  tableViewExtension.swift
//  Lion Search
//
//  Created by Besher on 2018-01-15.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Cocoa

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    //MARK: - AUTO COMPLETE FUNCTION
    
    func autoComplete() {
        guard srchField.stringValue.count > 1 && !users.isEmpty && srchField.stringValue != user.username else {
            autoCompleteScrollView.isHidden = true
            return }
        
        
        autoCompleteScrollView.isHidden = false
        displayedUsers.removeAll()
        let searchValue = srchField.stringValue.lowercased()
        for word in self.users {
            if word.lowercased().hasPrefix(searchValue) {
                self.displayedUsers.append(word)
            }
        }
        displayedUsers.sort()
        if (displayedUsers.count == 1) && srchField.stringValue == displayedUsers[0].replacingOccurrences(of: "\r", with: "") {
            autoCompleteScrollView.isHidden = true
            return
        }
        tableView.reloadData()
        // Update Scroll row count:
        
        switch displayedUsers.count {
        case 0:
            autoCompleteScrollView.isHidden = true
        case 1:
            autoCompleteScrollView.frame.size = CGSize(width: 117, height: 22)
            autoCompleteScrollView.frame.origin = CGPoint(x: 161, y: 513)
        case 2:
            autoCompleteScrollView.frame.size = CGSize(width: 117, height: 42)
            autoCompleteScrollView.frame.origin = CGPoint(x: 161, y: 493)
        case 3:
            autoCompleteScrollView.frame.size = CGSize(width: 117, height: 63)
            autoCompleteScrollView.frame.origin = CGPoint(x: 161, y: 472)
        case 4:
            autoCompleteScrollView.frame.size = CGSize(width: 117, height: 80)
            autoCompleteScrollView.frame.origin = CGPoint(x: 161, y: 455)
        case 5:
            autoCompleteScrollView.frame.size = CGSize(width: 117, height: 101)
            autoCompleteScrollView.frame.origin = CGPoint(x: 161, y: 434)
        default:
            autoCompleteScrollView.frame.size = CGSize(width: 117, height: 109)
            autoCompleteScrollView.frame.origin = CGPoint(x: 161, y: 426)
        }
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return displayedUsers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let ADCell = NSUserInterfaceItemIdentifier("cell")
        if let cell = tableView.makeView(withIdentifier: ADCell, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = displayedUsers[row]
            return cell
        }
        return nil
    }
    
    
    //MARK: - CLICK ON AUTO-COMPLETE
    
    @objc func tableViewDidClick(){
        let row = tableView.clickedRow
        let column = tableView.clickedColumn
        let unselected = -1
        
        if row == unselected && column == unselected{
            tableViewDidDeselectRow()
            return
        } else if row != unselected && column != unselected{
            tableViewDidSelectRow(row)
            return
        } else if column != unselected && row == unselected{
            tableviewDidSelectHeader(column)
        }
    }
    
    private func tableViewDidDeselectRow() {
        // clicked outside row
    }
    
    private func tableViewDidSelectRow(_ row : Int){
        searchFromTable(row: row)
        
    }
    
    private func tableviewDidSelectHeader(_ column : Int){
        // header did select
    }
    
    
    func myKeyDownEvent(event: NSEvent) -> NSEvent
    {
        
        switch event.keyCode {
        case kReturn:
            guard let firstResponder = NSApp.keyWindow?.firstResponder else { break }
            if firstResponder == tableView && !displayedUsers.isEmpty {
                searchFromTable(row: tableView.selectedRow)
            }
            
            keyDown(with: event)
            returnKeyWasPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                returnKeyWasPressed = false
            }
        case kDownArrowKeyCode:
            autoCompleteScrollView.becomeFirstResponder()
            downArrowWasPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                downArrowWasPressed = false
            }
        case kUpArrowKeyCode:
            guard let firstResponder = NSApp.keyWindow?.firstResponder else { break }
            if tableView.selectedRow == 0 && firstResponder == tableView {
                srchField.window?.makeFirstResponder(srchField)
            }
            upArrowWasPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                upArrowWasPressed = false
            }
        default:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned self] in
                self.autoComplete()
            }
        }
        return event
    }
    
    
    
    func searchFromTable(row: Int) {
        srchField.stringValue = displayedUsers[row]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            [unowned self] in 
            self.srchField.stringValue = self.srchField.stringValue.replacingOccurrences(of: "\r", with: "")
            self.search()
            self.autoCompleteScrollView.isHidden = true
        }
    }
}
