//
//  ViewController.swift
//  Lion Search
//
//  Created by Besher on 2017-10-10.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Cocoa
let user = User()

class ViewController: NSViewController, NSTextFieldDelegate {
    
    
    // A whole lotta labels
    @IBOutlet weak var creativeCloud: NSImageView!
    @IBOutlet weak var acrobat: NSImageView!
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
    @IBOutlet weak var groupsBtn: NSButton!
    @IBOutlet weak var copyBtn: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertImage.animator().alphaValue = 0.0
        srchField.sendsWholeSearchString = true
        self.checkStatus()
      
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func perfSearch(_ sender: Any) {
 
        user.clearValues()
        spinner.isHidden = false
        spinner.startAnimation(srchField)
        let userID = srchField.stringValue
        if userID != "" {

                user.userData = user.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/Users/\(userID)")
            
                user.regex()
                self.updateLabels()
            
        }
        spinner.stopAnimation(srchField)
        spinner.isHidden = true
    }
    
    // Checks for LL domain bind and internet connection upon launch
    func checkStatus() {
        spinner.isHidden = false
        spinner.startAnimation(srchField)
        user.shell("dsconfigad", "-show")
        user.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/")
        if user.disconnected {
            animateAlert("show")
            fullNameLabel.textColor = NSColor.red
            fullNameLabel.stringValue = "No connection!"
            jobTitleLabel.stringValue = "You must be connected to the office network, or use VPN"
            spinner.stopAnimation(srchField)
            spinner.isHidden = true
            return
        }
        if !user.llBound {
            fullNameLabel.stringValue = "Mac is not bound to LL!"
            fullNameLabel.textColor = NSColor.red
            jobTitleLabel.stringValue = "Bind your Mac to global.publicisgroupe.net then rerun the app"
            animateAlert("show")
            spinner.stopAnimation(srchField)
            spinner.isHidden = true
            return
        }
        spinner.stopAnimation(srchField)
        spinner.isHidden = true
    }
    
    func updateLabels() {
        guard user.llBound == true else { return }
        clearLabels()
        animateAlert("hide")
        hitachiLabel.isHidden = true
        fullNameLabel.textColor = NSColor.black
        lockedLabel.textColor = NSColor.black
        disabledLabel.textColor = NSColor.black
        passExpLabel.textColor = NSColor.black
        if user.disconnected {
            animateAlert("show")
            fullNameLabel.textColor = NSColor.red
            fullNameLabel.stringValue = "No connection!"
            jobTitleLabel.stringValue = "You must be connected to the office network, or use VPN"
            return
        }
        if user.wrongID {
            animateAlert("show")
            fullNameLabel.stringValue = "Invalid user ID"
            fullNameLabel.textColor = NSColor.red
            shakeField(srchField)
            clearLabels()
            return
        }
        fullNameLabel.stringValue = user.fullName
        
        if user.jobTitle != "" {
            jobTitleLabel.stringValue = user.jobTitle
        } else {
            jobTitleLabel.stringValue = " "
        }
        hyperionCodeLabel.stringValue = user.hyperion
        if user.country != "" {
            if user.state != "" {
                countryLabel.stringValue = user.country + ", " + user.state
            }
            else {
                countryLabel.stringValue = user.country
            }
        } else {
            countryLabel.stringValue = user.state
        }
        locationLabel.stringValue = user.location
        brandLabel.stringValue = user.brand
      
        if user.locked {
            animateAlert("show")
            lockedLabel.stringValue = "Account is locked."
            lockedLabel.textColor = NSColor.red
            hitachiLabel.isHidden = false
        } else {
            lockedLabel.stringValue = "Account is not locked"
        }
        
        if user.disabled {
            animateAlert("show")
            disabledLabel.stringValue = "Account is disabled"
            disabledLabel.textColor = NSColor.red
        } else {
            disabledLabel.stringValue = "Account is not disabled"
        }
        if !user.expDate.contains("30828") {
            accExpLabel.stringValue = user.expDate
        } else if user.disabled {
            accExpLabel.stringValue = "Disabled"
        } else {
            accExpLabel.stringValue = "Permanent employee"
        }
        if user.daysRemaining > 0 {
            if case 0...18 = user.daysRemaining {
                passExpLabel.textColor = NSColor.orange
            }
            passExpLabel.stringValue = "\(user.daysRemaining) days left, on " + user.passExpDate
        } else {
            passExpLabel.stringValue = "Expired \(-user.daysRemaining) days ago, on " + user.passExpDate
            passExpLabel.textColor = NSColor.red
            animateAlert("show")
        }
        
        if user.badPassCount != "" {
            badPassLabel.stringValue = "\(user.badPassCount) times recently"
        } else {
            badPassLabel.stringValue = "0"
        }
        lastLogonLabel.stringValue = user.lastLogon
        emailLabel.stringValue = user.emailPrim
        if user.vpn {
            vpnLabel.stringValue = "Enabled"
        } else {
            vpnLabel.stringValue = "Disabled"
        }
        
        if user.lyncVoice {
            lyncLabel.stringValue = user.lyncNum

            
            let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: NSColor.blue,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
            lyncLabel.attributedStringValue = NSAttributedString(string: lyncLabel.stringValue, attributes: attributes)
            
        } else {
            lyncLabel.stringValue = "Lync Voice not activated"
        }
        
        mfaLabel.stringValue = String(user.mfa).capitalized
        if user.creativeCloud {
            creativeCloud.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))
            acrobat.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))
        } else if user.acrobat {
            creativeCloud.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
            acrobat.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))
        } else {
            creativeCloud.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
            acrobat.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
        }
        copyBtn.isEnabled = true
        groupsBtn.isEnabled = true
    }
    
    func clearLabels() {
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
        creativeCloud.image = NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))
        acrobat.image = NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))
        copyBtn.isEnabled = false
        groupsBtn.isEnabled = false
    }
    
    
    func animateAlert(_ status: String) {
        if status == "hide" {
            NSAnimationContext.runAnimationGroup({ _ in
                NSAnimationContext.current.duration = 0.1
                alertImage.animator().alphaValue = 0.0
            }, completionHandler:{
            })
        } else {
            NSAnimationContext.runAnimationGroup({ _ in
                NSAnimationContext.current.duration = 0.1
                alertImage.animator().alphaValue = 1.0
            }, completionHandler:{
            })
        }
    }
    
    @IBAction func clipButton(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let pasteboardString = "Report generated on: " + user.todaysDate + "\nFull name: " + fullNameLabel.stringValue + "\nJob title: " + jobTitleLabel.stringValue + "\nLocation: " + countryLabel.stringValue + ", " + locationLabel.stringValue + "\nBrand: " + brandLabel.stringValue + "\nHyperion Code: " + hyperionCodeLabel.stringValue + "\nLocked: " + lockedLabel.stringValue + "\nDisabled: " + disabledLabel.stringValue + "\nAccount expires on: " + accExpLabel.stringValue + "\nPassword expires on: " + passExpLabel.stringValue + "\nBad Password count: " + badPassLabel.stringValue + "\nLast Logon: " + lastLogonLabel.stringValue + "\nPrimary email: " + emailLabel.stringValue + "\nLync Voice: " + lyncLabel.stringValue + "\nVPN: " + vpnLabel.stringValue + "\nMFA Enforced: " + mfaLabel.stringValue + "\nCreative Cloud: \(user.creativeCloud)" + "\nAcrobat: \(user.acrobat)"
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


