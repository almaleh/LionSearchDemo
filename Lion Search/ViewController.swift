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
    var lyncVoice: Bool = false
    var lyncNum: String = ""
    var mfa: Bool = false
    var daysRemaining = 0
    var todaysDate: String = ""
    var disconnected = false
    var wrongID = false
    var llBound = true
    
    // A whole lotta labels
    @IBOutlet weak var alertImage: NSImageView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var srchField: NSSearchField!
    @IBOutlet weak var fullNameLabel: NSTextField!
    @IBOutlet weak var jobTitleLabel: NSTextField!
    @IBOutlet weak var hyperionCodeLabel: NSTextField!
    @IBOutlet weak var countryLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
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
    @IBOutlet weak var hitachiLabel: NSTextField!
    @IBOutlet weak var disabledLabel: NSTextField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       alertImage.animator().alphaValue = 0.0
        
        srchField.sendsWholeSearchString = true
        
        
        
        
        
            self.checkStatus()
      
        
        // Do any additional setup after loading the view.
    }

    
    
    override func viewWillAppear() {
        
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // Shell Directory Utility method
    
        @discardableResult
        func shell(_ args: String...) -> String {
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = args
    
            let pipe = Pipe()
            task.standardOutput = pipe
    
//            DispatchQueue.global().async {
                task.launch()
//            }
//            task.launch()
//            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            guard let output: String = String(data: data, encoding: .utf8) else {
                return ""
            }
            
            
            if args[0].contains("dsconfigad") {
                guard output.contains("global.publicisgroupe.net") else { print("UNBOUND")
                    llBound = false
                    fullNameLabel.stringValue = "Mac is not bound to LL!"
                    fullNameLabel.textColor = NSColor.red
                    jobTitleLabel.stringValue = "Bind your Mac to global.publicisgroupe.net then rerun the app"
                    animateAlert("show")
                    
                    return "UNBOUND" }
            } else if llBound {
                guard !output.contains("read: Invalid Path") else { print ("DISCONNECTED")
                    disconnected = true
                    return "DISCONNECTED" }
                guard output.contains("dsAttrTypeNative") else { print("WRONG ID")
                    wrongID = true
                    return "WRONG ID" }
            }
            
            disconnected = false
            wrongID = false
            return output
        
        }

    // Regular expression look-up method
    
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
        if userData.contains("lockoutTime:") {
            locked = !userData.contains("lockoutTime: 0")
        }
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
        
        
    }
    
    @IBAction func perfSearch(_ sender: Any) {
 
        spinner.isHidden = false
        spinner.startAnimation(srchField)
        let userID = srchField.stringValue
        if userID != "" {

                self.userData = self.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/Users/\(userID)")
            
                self.regex()
                self.updateLabels()
            
        }
        spinner.stopAnimation(srchField)
        spinner.isHidden = true
    }
    
    // Checks for LL domain bind and internet connection upon launch
    func checkStatus() {
        spinner.isHidden = false
        spinner.startAnimation(srchField)
        self.shell("dsconfigad", "-show")
        self.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/")
        if disconnected {
            animateAlert("show")
            fullNameLabel.textColor = NSColor.red
            fullNameLabel.stringValue = "No connection!"
            jobTitleLabel.stringValue = "You must be connected to the office network, or use VPN"
            return
        }
        spinner.stopAnimation(srchField)
        spinner.isHidden = true
    }
    
    
    
    func updateLabels() {
        guard llBound == true else { return }
        animateAlert("hide")
        hitachiLabel.isHidden = true
        fullNameLabel.textColor = NSColor.black
        lockedLabel.textColor = NSColor.black
        disabledLabel.textColor = NSColor.black
        passExpLabel.textColor = NSColor.black
        if disconnected {
            animateAlert("show")
            fullNameLabel.textColor = NSColor.red
            fullNameLabel.stringValue = "No connection!"
            jobTitleLabel.stringValue = "You must be connected to the office network, or use VPN"
            return
        }
        if wrongID {
            animateAlert("show")
            fullNameLabel.stringValue = "Invalid user ID"
            fullNameLabel.textColor = NSColor.red
            shakeField(srchField)
            jobTitleLabel.stringValue = ""
            hyperionCodeLabel.stringValue = ""
            countryLabel.stringValue = ""
            locationLabel.stringValue = ""
            brandLabel.stringValue = ""
            lockedLabel.stringValue = ""
            disabledLabel.stringValue = ""
            accExpLabel.stringValue = ""
            passExpLabel.stringValue = ""
            badPassLabel.stringValue = ""
            lastLogonLabel.stringValue = ""
            emailLabel.stringValue = ""
            vpnLabel.stringValue = ""
            lyncLabel.stringValue = ""
            mfaLabel.stringValue = ""

            return
        }

        
        fullNameLabel.stringValue = fullName
        jobTitleLabel.stringValue = jobTitle
        hyperionCodeLabel.stringValue = hyperion
        if country != "" {
            countryLabel.stringValue = country + ", " + state
        } else {
            countryLabel.stringValue = state
        }
        locationLabel.stringValue = location
        brandLabel.stringValue = brand
      
        if locked {
            animateAlert("show")
            lockedLabel.stringValue = "Account is locked."
            lockedLabel.textColor = NSColor.red
            hitachiLabel.isHidden = false
        } else {
            lockedLabel.stringValue = "Account is not locked"
        }
        
        if disabled {
            animateAlert("show")
            disabledLabel.stringValue = "Account is disabled"
            disabledLabel.textColor = NSColor.red
        } else {
            disabledLabel.stringValue = "Account is not disabled"
        }
        if !expDate.contains("30828") {
            accExpLabel.stringValue = expDate
        } else if disabled {
            accExpLabel.stringValue = "Disabled"
        } else {
            accExpLabel.stringValue = "Permanent employee"
        }
        if daysRemaining >= 0 {
            if case 0...18 = daysRemaining {
                passExpLabel.textColor = NSColor.orange
            }
            passExpLabel.stringValue = "\(daysRemaining) days left, on " + passExpDate
        } else {
            passExpLabel.stringValue = "Expired \(-daysRemaining) days ago, on " + passExpDate
            passExpLabel.textColor = NSColor.red
            animateAlert("show")
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
            
            
            let attributes: [String: AnyObject] = [
                NSForegroundColorAttributeName: NSColor.blue,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
            ]
            lyncLabel.attributedStringValue = NSAttributedString(string: lyncLabel.stringValue, attributes: attributes)
            
        } else {
            lyncLabel.stringValue = "Lync Voice not activated"
        }
        
        mfaLabel.stringValue = String(mfa).capitalized
        
        
    }
    
    func animateAlert(_ status: String) {
        if status == "hide" {
            NSAnimationContext.runAnimationGroup({ _ in
                NSAnimationContext.current().duration = 0.2
                alertImage.animator().alphaValue = 0.0
            }, completionHandler:{
            })
        } else {
            NSAnimationContext.runAnimationGroup({ _ in
                NSAnimationContext.current().duration = 0.2
                alertImage.animator().alphaValue = 1.0
            }, completionHandler:{
            })
        }
    }
    
    @IBAction func clipButton(_ sender: Any) {
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        let pasteboardString = "Report generated on: " + todaysDate + "\n\nFull name: " + fullNameLabel.stringValue + "\nJob title: " + jobTitleLabel.stringValue + "\nLocation: " + countryLabel.stringValue + ", " + locationLabel.stringValue +  "\nHyperion Code: " + hyperionCodeLabel.stringValue + "\nLocked: " + lockedLabel.stringValue + "\nDisabled: " + disabledLabel.stringValue + "\nAccount expires on: " + accExpLabel.stringValue + "\nPassword expires on: " + passExpLabel.stringValue + "\nBad Password count: " + badPassLabel.stringValue + "\nLast Logon: " + lastLogonLabel.stringValue + "\nPrimary email: " + emailLabel.stringValue + "\nLync Voice: " + lyncLabel.stringValue + "\nVPN: " + vpnLabel.stringValue + "\nMFA Enforced: " + mfaLabel.stringValue
        pasteboard.setString(pasteboardString, forType: NSPasteboardTypeString)
        
    }
    
    @IBAction func lyncCall(_ sender: Any) {
        guard lyncNum != "" else { return }
        var number = lyncNum
        if lyncNum.contains("+") {
            number.remove(at: lyncNum.startIndex)
        }
        NSWorkspace.shared().open(URL(string: "tel:" + number)!)
    }
    
    @IBAction func helpBtn(_ sender: Any) {

            NSWorkspace.shared().open(URL(string: "https://lion.box.com/v/LionSearchHelp")!)
        
    }
    
    func shakeField(_ field: NSSearchField) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, -5, 5, -5, 0 ]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        animation.duration = 0.4
        animation.isAdditive = true
        field.layer?.add(animation, forKey: "shake")
    }


}

