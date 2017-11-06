//
//  User.swift
//  Lion Search
//
//  Created by Besher on 2017-10-17.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Foundation

class User {
    
    var username: String = ""
    var userData: String = ""
    var userData2: String = ""
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
    var creativeCloud = false
    var acrobat = false
    var groupList = ""
    var groups = [String]()
    var city = ""
    
    @discardableResult
    func shell(_ args: String...) -> String {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        
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
    
    //MARK: - Regular expression look-up method
    
    func regex() {
        
        
        let hypPat = "(?<=hcode: )\\w{6}"
        let namePat = "(?<=RealName:\\n )[^\\n]*"
        let countryPat = "(?<=Native:co: )[^\\n]+\\b"
        let countryPat2 = "(?<=Native:co:\\n )[^\\n]+\\b"
        let statePat = "(?<=\\bState:\\n )[^\\n]+\\b"
        let statePat2 = "(?<=\\bState: )[^\\n]+\\b"
        let locationPat = "(?<=Street:\\n )[^\\n]*"
        let brandPat = "(?<=Native:company: )\\w+\\b"
        let brandPat2 = "(?<=Native:company:\\n )[^\\n]+\\b"
        let jobPat = "(?<=JobTitle: ).*\\n(?=LastName:)"
        let jobPat2 = "(?<=JobTitle:\\n ).*\\n(?=LastName:)"
        let passCountPat = "(?<=badPwdCount: )\\w+\\b"
        let emailPrimPat = "(?<=EMailAddress: )[^\\n]+"
        let lyncNumPat = "(?<=tel:)[^\\n]+"
        let expDatePat = "(?<=accountExpires: )\\w+\\b"
        let passUpdatePat = "(?<=PasswordLastSet: )[^(\n)]+"
        let badPassTimePat = "(?<=badPasswordTime: )\\w+\\b"
        let lastLogonPat1 = "(?<=lastLogon: )\\w+\\b"
        let lastLogonPat2 = "(?<=lastLogonTimestamp: )\\w+\\b"
        let groupListPat = "(?<=memberOf:\\n )[^*]*?(?=\\ndsAttrTypeNative)"
        let groupMemberPat = "(?<=CN=)[^,]+(?=,)"
        let cityPat = "(?<=\\City:\\n )[^\\n]+\\b"
        let cityPat2 = "(?<=\\City: )[^\\n]+\\b"
        
        //MARK: - CONVERT FROM LDAP TIME TO UNIX TIME:
        func msToUNIX(_ input: Double) -> Double {
            return (input / 10000000) - 11644473600
        }
        
        //MARK: - CONVERT FROM UNIX TIME TO FORMATTED DATE:
        
        func formatDate(_ unix: Double) -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let date = Date(timeIntervalSince1970: unix)
            
            // US English Locale (en_US)
            dateFormatter.locale = Locale(identifier: "en_US")
            return dateFormatter.string(from: date)
        }
        
        func formatDateOnly(_ unix: Double) -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            let date = Date(timeIntervalSince1970: unix)
            
            // US English Locale (en_US)
            dateFormatter.locale = Locale(identifier: "en_US")
            return dateFormatter.string(from: date)
        }
        
        
        //MARK: - REGEX PATTERN MATCHING:
        func reg(_ pat: String) -> String {
            var output = ""
            let regStr = userData
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: regStr, options: [], range: NSRange(location: 0, length: regStr.characters.count))
            
            
            for match in matches {
                for n in 0..<match.numberOfRanges {
                    let range = match.range(at: n)
                    let rstart = regStr.startIndex
                    let r = regStr.characters.index(rstart, offsetBy: range.location) ..<
                        regStr.characters.index(rstart, offsetBy: range.location + range.length)
                    output = regStr.substring(with: r)
                }
            }
            return output
        }
        
        //MARK: - REGEX PATTERN FOR MEMBER GROUPS:
        
        func regGroup(_ pat: String, regStr: String) -> [String] {
            var output = ""
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: regStr, options: [], range: NSRange(location: 0, length: regStr.characters.count))
            
            
            for match in matches {
                for n in 0..<match.numberOfRanges {
                    let range = match.range(at: n)
                    let rstart = regStr.startIndex
                    let r = regStr.characters.index(rstart, offsetBy: range.location) ..<
                        regStr.characters.index(rstart, offsetBy: range.location + range.length)
                    output = regStr.substring(with: r)
                    groups.append(output)
                }
            }
            return groups
        }
        
        //MARK: - VARS FOR TIME-BASED REGEX BEFORE BUSINESS CATEGORY CHECK
        
        var badPassInterval: Double = 0
        var lastLogonInterval1: Double = 0
        var lastLogonInterval2: Double = 0
        var expInterval: Double = 0
        var passInterval: Double = 0
        
        badPassCount = reg(passCountPat)
        
        
        if let opt = Double(reg(expDatePat)) {
            expInterval = opt
        } else {
            print("EXPDATEPAT")
        }
        
        if let opt = Double(reg(badPassTimePat)) {
            badPassInterval = opt
        } else {
            print("BADPASSTIMEPAT")
        }
        
        
        
        //MARK: - CHECK FOR NULL CHARACTERS IN BUSINESS CATEGORY
        
        if userData.contains("\nRemoteAccessVPN") {
            if let range = userData.range(of: "\nRemoteAccessVPN") {
                userData = String(userData[range.upperBound...])
                print(userData2)
                
            }
        }
        
        city = reg(cityPat)
        if city == "" {
            city = reg(cityPat2)
        }
        print(city)
        groupList = reg(groupListPat)
        groups = regGroup(groupMemberPat, regStr: groupList)
        groups.sort()
        hyperion = reg(hypPat)
        fullName = reg(namePat)
        country = reg(countryPat)
        if country == "" {
            country = reg(countryPat2)
        }
        state = reg(statePat)
        if state == "" {
            state = reg(statePat2)
        }
        location = reg(locationPat)
        brand = reg(brandPat)
        if brand == "" {
            brand = reg(brandPat2)
        }
        jobTitle = reg(jobPat)
        if jobTitle == "" {
            jobTitle = reg(jobPat2)
        }
        vpn = userData.contains("RemoteAccessVPN")
        if userData.contains("lockoutTime:") {
            locked = !userData.contains("lockoutTime: 0")
        }
        disabled = !userData.contains(":userAccountControl: 512")
        
        emailPrim = reg(emailPrimPat)
        lyncVoice = userData.contains("dsAttrTypeNative:msRTCSIP-Line:")
        lyncNum = reg(lyncNumPat)
        passUpdateDate = reg(passUpdatePat)
        mfa = userData.contains("LionBOX-MFA")
        creativeCloud = userData.contains("ADOBE-CC")
        
        if creativeCloud {
            acrobat = true
        } else {
            acrobat = userData.contains("ACROBAT")
        }
        
        if let opt = Double(reg(passUpdatePat)) {
            passInterval = opt
        } else {
            print("PASSUPDATEPAT")
        }
        
        
        if let opt = Double(reg(lastLogonPat1)) {
            lastLogonInterval1 = opt
        } else {
            print("LASTLOGON")
        }
        
        if let opt = Double(reg(lastLogonPat2)) {
            lastLogonInterval2 = opt
        } else {
            print("LASTLOGONPAT")
        }
        
        let unixExp = msToUNIX(expInterval)
        let unixPass = msToUNIX(passInterval)
        let unixBadPass = msToUNIX(badPassInterval)
        let unixToday = Date().timeIntervalSince1970
        let unixPassExpDate = unixPass + ( 86400 * 90 )
        daysRemaining = Int(90 - ((unixToday - unixPass) / 86400))
        let unixLastLogon = lastLogonInterval1 > lastLogonInterval2 ? msToUNIX(lastLogonInterval1) : msToUNIX(lastLogonInterval2)
        
        if unixExp > 0 {
            expDate = formatDate(unixExp)
        } else {
            expDate = "30828"
        }
        
        passUpdateDate = formatDate(unixPass)
        passExpDate = formatDateOnly(unixPassExpDate)
        badPassTime = formatDate(unixBadPass)
        let lastLogonDays = Int((unixToday - unixLastLogon) / 86400)
        switch lastLogonDays {
        case 0...7:
            lastLogon = "Less than a week ago"
        case 7...30:
            lastLogon = "Less than a month ago"
        case 30...60:
            lastLogon = "1 month ago"
        case 60...90:
            lastLogon = "2 months ago"
        case 90...120:
            lastLogon = "3 months ago"
        case 120...150:
            lastLogon = "4 months ago"
        case 150...180:
            lastLogon = "5 months ago"
        case 180...365:
            lastLogon = "Over 6 months ago"
        case 365...730:
            lastLogon = "Over a year ago"
        case 730...1095:
            lastLogon = "Over two years ago"
        case 1095...1460:
            lastLogon = "Over three years ago"
        default:
            lastLogon = "Over four years ago"
        }
        todaysDate = formatDate(unixToday)
        
        
    }
    
    func clearValues() {
        
        jobTitle = ""
        hyperion = ""
        country = ""
        state = ""
        location = ""
        brand = ""
        locked = false
        disabled = false
        expDate = ""
        passExpDate = ""
        badPassCount = ""
        lastLogon = ""
        emailPrim = ""
        vpn = false
        lyncVoice = false
        mfa = false
        groups = []
        username = ""
        city = ""
    }
    
    
}

