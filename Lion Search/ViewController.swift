//
//  ViewController.swift
//  Lion Search
//
//  Created by Besher on 2017-10-10.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate, NSSearchFieldDelegate {
    
    
    @IBOutlet weak var autoCompleteScrollView: NSScrollView!
    @IBOutlet weak var creativeCloud: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
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
    var displayedUsers = [String]()
    var usersArray = [String]()
    var users = Set<String>()
    let versionNumber = String(describing:Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if #available(OSX 10.11, *) {
            srchField.delegate = self
        } else {
            // Fallback on earlier versions
        }
        autoCompleteScrollView.isHidden = true
        tableView.target = self
        tableView.action = #selector(tableViewDidClick)

        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: myKeyDownEvent)
    
        alertImage.animator().alphaValue = 0.0
//        self.checkStatus()
        fetchADList()
        
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
        
        var possCity = ""
        if user.city != "" {
            possCity = ", \(user.city)"
        }
        var possState = ""
        if user.state != "" {
            possState = ", \(user.state)"
        }
        
        if user.country != "" {
            countryLabel.stringValue = user.country + possState + possCity
        } else if user.state != "" {
            countryLabel.stringValue = user.state + possCity
        } else {
            countryLabel.stringValue = user.city
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
            if case 0...15 = user.daysRemaining {
                passExpLabel.textColor = NSColor.orange
            }
            passExpLabel.stringValue = "\(user.daysRemaining) days left, on " + user.passExpDate
        } else if user.daysRemaining == 0 {
            
            passExpLabel.textColor = NSColor.orange
            passExpLabel.stringValue = "Expires soon! On " + user.passExpDate
        
        } else {
            passExpLabel.stringValue = "Expired \(-user.daysRemaining) days ago, on " + user.passExpDate
            passExpLabel.textColor = NSColor.red
            animateAlert("show")
        }
        
        if user.badPassCount != "" {
            if user.badPassCount == "0" {
                badPassLabel.stringValue = "None recently"
            } else {
                badPassLabel.stringValue = "\(user.badPassCount) times recently"
            }
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
        
        if user.mfa {
            mfaLabel.stringValue = "Enforced"
        } else {
            mfaLabel.stringValue = "Not enforced" 
        }
        
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
    
    
    
    
    //MARK: - Shake Animation
    
    func shakeField(_ field: NSSearchField) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, -5, 5, -5, 0 ]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        animation.duration = 0.4
        animation.isAdditive = true
        field.layer?.add(animation, forKey: "shake")
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
    
    
    
    //MARK: - Fetch AD list and check for updates
    
    func fetchADList() {
        let fm = FileManager.default
        DispatchQueue.global().async {
            [unowned self] in
            if let listPath = Bundle.main.path(forResource: "names", ofType: "txt") {
                if let list = try? String(contentsOfFile: listPath) {
                    self.usersArray = list.components(separatedBy: "\n")
                    self.users = Set(self.usersArray)
                }
            }
            print(self.users)
            
            
            if let urlUpdate = URL(string: "https://lion.box.com/shared/static/sip0jucsj9j6llw8tyjkf0kxto6ji1nd.txt" ) {
                if let onlineVersion = try? String(contentsOf: (urlUpdate)) {
                    let start = onlineVersion.startIndex
                    let end = onlineVersion.index(start, offsetBy: 3)
                    if onlineVersion[start...end] > self.versionNumber {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            let _ = self.dialogOKCancel(question: "An update is available!", text: "Version \(onlineVersion[start...end]) is now available. Would you like to download it?")
                        }
                    }
                }
            }
        }
    }
    
    

    
    override func keyDown(with event: NSEvent) {
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if let destinationViewController = segue.destinationController as? SheetViewController {
            destinationViewController.userData = user
        }
    }
    
}


