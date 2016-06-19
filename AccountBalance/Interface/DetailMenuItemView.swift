//
//  MenuItemView.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 19/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

enum MessageType {
    case Info
    case Error
    
    var color: NSColor {
        switch self {
        case .Info:
            return NSColor.blackColor()
        case .Error:
            return NSColor.redColor()
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
    
    func showAccountView(accountBalance: AccountBalance) {
        loginView.hidden = true
        accountView.hidden = false
        messageView.hidden = true
        
        dispatch_async(dispatch_get_main_queue()) {
            self.providerImage.image = self.preferences.getProvider().image
            self.userLabel.stringValue = accountBalance.username
        }
    }
    
    func showLoginView() {
        loginView.hidden = false
        accountView.hidden = true
        messageView.hidden = true
    }
    
    func showMessageView(message: String, messageType: MessageType) {
        loginView.hidden = true
        accountView.hidden = true
        messageView.hidden = false
        
        messageLabel.textColor = messageType.color
        messageLabel.stringValue = message
    }
}
