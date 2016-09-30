//
//  MenuItemView.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 19/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

enum MessageType {
    case info
    case error
    
    var color: NSColor {
        switch self {
        case .info:
            return NSColor.black
        case .error:
            return NSColor.red
        }
    }
}

class DetailMenuItemView: NSView {
    
    @IBOutlet weak var accountView: NSView!
    @IBOutlet weak var providerImage: NSImageView!
    @IBOutlet weak var userLabel: NSTextField!
    
    @IBOutlet weak var loginView: NSView!
    
    @IBOutlet weak var messageView: NSView!
    @IBOutlet weak var messageLabel: NSTextField!
    
    let preferences = AppPreferences.sharedInstance
    
    func showAccountView(_ accountBalance: AccountBalance) {
        loginView.isHidden = true
        accountView.isHidden = false
        messageView.isHidden = true
        
        DispatchQueue.main.async {
            self.providerImage.image = self.preferences.getProvider().image
            self.userLabel.stringValue = accountBalance.username
        }
    }
    
    func showLoginView() {
        loginView.isHidden = false
        accountView.isHidden = true
        messageView.isHidden = true
    }
    
    func showMessageView(_ message: String, messageType: MessageType) {
        loginView.isHidden = true
        accountView.isHidden = true
        messageView.isHidden = false
        
        messageLabel.textColor = messageType.color
        messageLabel.stringValue = message
    }
}
