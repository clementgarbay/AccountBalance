//
//  AccountView.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 19/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

class AccountView: NSView {
    
    @IBOutlet weak var providerImage: NSImageView!
    @IBOutlet weak var userLabel: NSTextField!
    
    let preferences = AppPreferences.sharedInstance
    
    func update(accountBalance: AccountBalance) {
        dispatch_async(dispatch_get_main_queue()) {
            self.providerImage.image = self.preferences.getProvider().image
            self.userLabel.stringValue = accountBalance.username
        }
    }
}
