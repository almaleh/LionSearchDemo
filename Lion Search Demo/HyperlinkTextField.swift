//
//  hyperlink.swift
//  Lion Search
//
//  Created by Besher on 2017-10-12.
//  Copyright © 2017 Besher Al Maleh. All rights reserved.
//

import Cocoa

@IBDesignable
class HyperTextField: NSTextField {
    @IBInspectable var href: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: NSColor.blue,
                                                        NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)

    }
    
    override func mouseDown(with event: NSEvent) {
        NSWorkspace.shared.open(URL(string: self.href)!)
    }
}
