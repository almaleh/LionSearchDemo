//
//  ViewController.swift
//  Lion Search
//
//  Created by Besher on 2017-10-10.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTextFieldDelegate {
    
    var username: String = ""
    var userData: String = ""
    var fullName: String = ""
    var hyperion: String = ""
    var country: String = ""
    var state: String = ""
    var location: String = ""
    var brand: String = ""
    var jobTitle: String = ""
    var vpn: Bool = false
    var expired: Bool = false
    var expDate: String = ""
    var passUpdateDate: String = ""
    var passExpDate: String = ""
    var locked: Bool = false
    var disabled: Bool = false
    var badPassCount: String = ""
    var badPassTime: String = ""
    var lastLogon: String = ""
    var emailPrim: String = ""
//    var emailProx: String = ""
    var lyncVoice: Bool = false
    var lyncNum: String = ""
    var mfa: Bool = false
    var daysRemaining = 0
    var todaysDate: String = ""
    
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var srchField: NSSearchField!
    @IBOutlet weak var fullNameLabel: NSTextField!
    @IBOutlet weak var jobTitleLabel: NSTextField!
    @IBOutlet weak var hyperionCodeLabel: NSTextField!
    @IBOutlet weak var countryLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var background: NSView!
    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var passExpLabel: NSTextField!
    
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var lastLogonLabel: NSTextField!
    @IBOutlet weak var badPassLabel: NSTextField!
    @IBOutlet weak var accExpLabel: NSTextField!
    @IBOutlet weak var brandLabel: NSTextField!
    @IBOutlet weak var vpnLabel: NSTextField!
    @IBOutlet weak var lyncLabel: NSTextField!
    @IBOutlet weak var mfaLabel: NSTextField!
    
    @IBOutlet weak var lockedLabel: NSTextField!
    
    @IBOutlet weak var disabledLabel: NSTextField!
    

    
    override func viewDidLoad() {
        

        
        super.viewDidLoad()
        srchField.sendsWholeSearchString = true
        
        // Do any additional setup after loading the view.
    }

    
    
    override func viewWillAppear() {
        background.alphaValue = 0
        background.layer?.backgroundColor = NSColor.gray.cgColor
        //box.layer?.setNeedsDisplay()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    
        @discardableResult
        func shell(_ args: String...) -> String {
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = args
    
            let pipe = Pipe()
            task.standardOutput = pipe
    
            task.launch()
//            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            guard let output: String = String(data: data, encoding: .utf8) else {
                return ""
            }
            
            guard !output.contains("read: Invalid Path") else { print ("DISCONNECTED")
                return "DISCONNECTED" }
            
            guard output.contains("dsAttrTypeNative") else { print("WRONG ID")
                return "WRONG ID" }
            
            return output
        }

    func regex() {
        
        
        let hypPat = "(?<=hcode: )\\w{6}"
        let namePat = "(?<=RealName:\\n )[^\\n]*"
        let countryPat = "(?<=Native:co: )\\w+\\b"
        let statePat = "(?<=State: )\\w+\\b"
        let locationPat = "(?<=Street:\\n )[^\\n]*"
        let brandPat = "(?<=Native:company: )\\w+\\b"
        let jobPat = "(?<=JobTitle:\\n )[^\\n]*"
        let passCountPat = "(?<=badPwdCount: )\\w+\\b"
        let emailPrimPat = "(?<=EMailAddress: )[^\\n]+"
//        let emailProxPat = "(?<=smtp:).+"
        let lyncNumPat = "(?<=tel:)[^\\n]+"
        let expDatePat = "(?<=accountExpires: )\\w+\\b"
        let passUpdatePat = "(?<=PasswordLastSet: )[^(\n)]+"
        let badPassTimePat = "(?<=badPasswordTime: )\\w+\\b"
        let lastLogonPat1 = "(?<=lastLogon: )\\w+\\b"
        let lastLogonPat2 = "(?<=lastLogonTimestamp: )\\w+\\b"
        
        //CONVERT FROM LDAP TIME TO UNIX TIME:
        func msToUNIX(_ input: Double) -> Double {
            return (input / 10000000) - 11644473600
        }
        
        
        //CONVERT FROM UNIX TIME TO FORMATTED DATE:
        
        func formatDate(_ unix: Double) -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let date = Date(timeIntervalSince1970: unix)
            
            // US English Locale (en_US)
            dateFormatter.locale = Locale(identifier: "en_US")
            return dateFormatter.string(from: date)
        }
        

        
        
        //REGEX PATTERN MATCHING:
        func reg(_ pat: String) -> String {
            var output = ""
            let regStr = userData
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: regStr, options: [], range: NSRange(location: 0, length: regStr.characters.count))
            
            
            for match in matches {
                for n in 0..<match.numberOfRanges {
                    let range = match.rangeAt(n)
                    let rstart = regStr.startIndex
                    let r = regStr.characters.index(rstart, offsetBy: range.location) ..<
                        regStr.characters.index(rstart, offsetBy: range.location + range.length)
                    output = regStr.substring(with: r)
                }
            }
            return output
        }
        

        hyperion = reg(hypPat)
        fullName = reg(namePat)
        country = reg(countryPat)
        state = reg(statePat)
        location = reg(locationPat)
        brand = reg(brandPat)
        jobTitle = reg(jobPat)
        vpn = userData.contains("RemoteAccessVPN")
        locked = !userData.contains("lockoutTime: 0")
        disabled = !userData.contains(":userAccountControl: 512")
        badPassCount = reg(passCountPat)
        emailPrim = reg(emailPrimPat)
//        emailProx = reg(emailProxPat)
        lyncVoice = userData.contains("LyncVoice:ACTIVATED")
        lyncNum = reg(lyncNumPat)
        passUpdateDate = reg(passUpdatePat)
        mfa = userData.contains("LionBOX-MFA")
        
        guard let expInterval: Double = Double(reg(expDatePat)) else { return }
        guard let passInterval: Double = Double(reg(passUpdatePat)) else { return }
        guard let badPassInterval: Double = Double(reg(badPassTimePat)) else { return }
        guard let lastLogonInterval1: Double = Double(reg(lastLogonPat1)) else { return }
        guard let lastLogonInterval2: Double = Double(reg(lastLogonPat2)) else { return }
        
        let unixExp = msToUNIX(expInterval)
        let unixPass = msToUNIX(passInterval)
        let unixBadPass = msToUNIX(badPassInterval)
        let unixToday = Date().timeIntervalSince1970
        let unixPassExpDate = unixPass + ( 86400 * 90 )
        daysRemaining = Int(90 - ((unixToday - unixPass) / 86400))
        let unixLastLogon = lastLogonInterval1 > lastLogonInterval2 ? msToUNIX(lastLogonInterval1) : msToUNIX(lastLogonInterval2)
    
        
        expDate = formatDate(unixExp)
        passUpdateDate = formatDate(unixPass)
        passExpDate = formatDate(unixPassExpDate)
        badPassTime = formatDate(unixBadPass)
        lastLogon = formatDate(unixLastLogon)
        todaysDate = formatDate(unixToday)
        
        print("Hyperion code: " + hyperion)
        print("Full name: " + fullName)
        print("Country: " + country + ", " + state)
        print("Location: " + location)
        print("Brand: " + brand)
        print("Job title: " + jobTitle)
        print("VPN: " + String(vpn).capitalized)
        print("Locked: " + String(locked).capitalized)
        print("Disabled: " + String(disabled).capitalized)
        print("Bad password count: " + badPassCount)
        print("Bad password time: " + badPassTime)
        print("Primary e-mail address: " + emailPrim)
//        print("Proxy e-mail: " + emailProx)
        print("Lync Voice activated: " + String(lyncVoice).capitalized)
        if lyncVoice {
            print("Lync number: " + lyncNum)
        }
        if !expDate.contains("30828") {
            print("Account expires on: " + expDate)
        } else if disabled {
            print("Account expires on: Disabled")
        } else {
            print("Expiration date: Permanent employee")
        }
        print("Password was last updated on: " + passUpdateDate)
        if daysRemaining >= 0 {
            print("Password expires in \(daysRemaining) days, on " + passExpDate)
        } else {
            print("Password has expired \(-daysRemaining) days ago, on " + passExpDate)
        }
        
        print("MFA Enforcement: " + String(mfa).capitalized)
        print("The user has last logged in on: " + lastLogon)
    }
    
    @IBAction func perfSearch(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimation(srchField)
        let userID = srchField.stringValue
        if userID != "" {
//            DispatchQueue.main.async { [unowned self] in
                self.userData = self.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/Users/\(userID)")
                self.regex()
                self.updateLabels()
                background.alphaValue = 0
                self.updateColors()
//            }
        }
        
        spinner.stopAnimation(srchField)
        spinner.isHidden = true

    }
    
    func updateLabels() {
        
        fullNameLabel.stringValue = fullName
        jobTitleLabel.stringValue = jobTitle
        hyperionCodeLabel.stringValue = hyperion
        countryLabel.stringValue = country
        locationLabel.stringValue = location
        stateLabel.stringValue = state
        brandLabel.stringValue = brand
        lockedLabel.stringValue = String(locked).capitalized
        disabledLabel.stringValue = String(disabled).capitalized
        if !expDate.contains("30828") {
            accExpLabel.stringValue = expDate
        } else if disabled {
            accExpLabel.stringValue = "Disabled"
        } else {
            accExpLabel.stringValue = "Permanent employee"
        }
        if daysRemaining >= 0 {
            passExpLabel.stringValue = "\(daysRemaining) days left, on " + passExpDate
        } else {
            passExpLabel.stringValue = "Expired \(-daysRemaining) days ago, on " + passExpDate
        }
        badPassLabel.stringValue = "\(badPassCount) times recently"
        lastLogonLabel.stringValue = lastLogon
        emailLabel.stringValue = emailPrim
        if vpn {
            vpnLabel.stringValue = "Enabled"
        } else {
            vpnLabel.stringValue = "Disabled"
        }
        
        if lyncVoice {
            lyncLabel.stringValue = lyncNum
        } else {
            lyncLabel.stringValue = "Lync Voice disabled"
        }
        
        mfaLabel.stringValue = String(mfa).capitalized
        
        
    }
    
    func updateColors() {
        if disabled {
            background.alphaValue = 0.7
            
        }
    }
    
    @IBAction func clipButton(_ sender: Any) {
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        let pasteboardString = "Report generated on: " + todaysDate + "\n\nFull name: " + fullNameLabel.stringValue + "\nJob title: " + jobTitleLabel.stringValue + "\nCountry: " + countryLabel.stringValue + "\nState: " + stateLabel.stringValue + "\nLocation: " + locationLabel.stringValue +  "\nHyperion Code: " + hyperionCodeLabel.stringValue + "\nLocked: " + lockedLabel.stringValue + "\nDisabled: " + disabledLabel.stringValue + "\nAccount expires on: " + accExpLabel.stringValue + "\nPassword expires on: " + passExpLabel.stringValue + "\nBad Password count: " + badPassLabel.stringValue + "\nLast Logon: " + lastLogonLabel.stringValue + "\nPrimary email: " + emailLabel.stringValue + "\nVPN: " + vpnLabel.stringValue + "\nLync Voice: " + lyncLabel.stringValue + "\nMFA Enforced: " + mfaLabel.stringValue
        pasteboard.setString(pasteboardString, forType: NSPasteboardTypeString)
        
    }

}

