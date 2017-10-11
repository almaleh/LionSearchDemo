//
//  ViewController.swift
//  Lion Search
//
//  Created by Besher on 2017-10-10.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    
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
    var locked: Bool = false
    var disabled: Bool = false
    var badPassCount: String = ""
//    var badPassTime: String = ""
//    var lastLogon: String = ""
    var emailPrim: String = ""
//    var emailProx: String = ""
    var lyncVoice: Bool = false
    var lyncNum: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

 

        
        DispatchQueue.main.async { [unowned self] in
            
            self.userData = self.shell("dscl", "localhost", "-read", "Active Directory/LL/All Domains/Users/plandry")
            self.regex()
        }
        
        
        
        
        
        
        

        
        
        // Do any additional setup after loading the view.
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
        let interval: Double = (Double(reg(expDatePat))! / 10000000) - 11644473600
       
        // TIME WORK // 
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        
        let date = Date(timeIntervalSince1970: interval)
        
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        expDate = (dateFormatter.string(from: date))
        
        // TIME WORK OVER //
        
        
        
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
        print("Primary e-mail address: " + emailPrim)
//        print("Proxy e-mail: " + emailProx)
        print("Lync Voice activated: " + String(lyncVoice).capitalized)
        if lyncVoice {
            print("Lync number: " + lyncNum)
        }

        if !expDate.contains("30828") {
            print("Expiration date: " + expDate)
        }
        
    }
    

}

