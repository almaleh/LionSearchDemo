//
//  ViewControllerButtons.swift
//  Lion Search
//
//  Created by Besher on 2018-01-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    
    
    @IBAction func perfSearch(_ sender: Any) {
        //        autoComplete()
        guard !recentSearch else { return }
        if returnKeyWasPressed {
            search()
        }
        
    }
    
    func search() {
        guard srchField.stringValue.count >= 4 else { return }
        if users.isEmpty {
            fetchADList()
        }
        
        recentSearch = true
        user.clearValues()
        spinner.isHidden = false
        spinner.startAnimation(srchField)
        user.username = srchField.stringValue
        if user.username != "" {
            
            user.userData = user.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/Users/\(user.username)")
            
            user.regex()
            self.updateLabels()
            
        }
        spinner.stopAnimation(srchField)
        spinner.isHidden = true
        autoCompleteScrollView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            recentSearch = false
        }
    }
    
    //MARK: - CLIPBOARD
    
    @IBAction func clipButton(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let pasteboardString = "Report generated on: " + user.todaysDate + "\n\nUsername: " + user.username + "\nFull name: " + fullNameLabel.stringValue + "\nJob title: " + jobTitleLabel.stringValue + "\nLocation: " + countryLabel.stringValue + ", " + locationLabel.stringValue + "\nBrand: " + brandLabel.stringValue + "\nHyperion Code: " + hyperionCodeLabel.stringValue + "\nLocked: " + lockedLabel.stringValue + "\nDisabled: " + disabledLabel.stringValue + "\nAccount expires on: " + accExpLabel.stringValue + "\nPassword expires on: " + passExpLabel.stringValue + "\nBad Password count: " + badPassLabel.stringValue + "\nLast Logon: " + lastLogonLabel.stringValue + "\nPrimary email: " + emailLabel.stringValue + "\nLync Voice: " + lyncLabel.stringValue + "\nVPN: " + vpnLabel.stringValue + "\nMFA (LionBox): " + mfaLabel.stringValue + "\nCreative Cloud: \(String(user.creativeCloud).capitalized)" + "\nAcrobat: \(String(user.acrobat).capitalized)"
        pasteboard.setString(pasteboardString, forType: NSPasteboard.PasteboardType.string)
    }
    //      LyncCall Functionality:
    @IBAction func lyncCall(_ sender: Any) {
        guard user.lyncNum != "" else { return }
        var number = user.lyncNum
        if user.lyncNum.contains("+") {
            number.remove(at: user.lyncNum.startIndex)
        }
        NSWorkspace.shared.open(URL(string: "tel:" + number)!)
    }
    
    @IBAction func helpBtn(_ sender: Any) {
        
        NSWorkspace.shared.open(URL(string: "https://lion.box.com/v/LionSearchHelp")!)
        
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Later")
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            NSWorkspace.shared.open(URL(string: "https://lion.box.com/v/LionSearch")!)
            return true
        case .alertSecondButtonReturn:
            return false
        default:
            return false
        }
        
        //        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
}
