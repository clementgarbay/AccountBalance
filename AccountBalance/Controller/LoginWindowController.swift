//
//  LoginViewController.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 18/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController {

    @IBOutlet weak var providerList: NSPopUpButton!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var loader: NSProgressIndicator!
    
    let preferences = AppPreferences.sharedInstance
    var delegate: AccountBalanceDelegate?
    
    override var windowNibName: String! {
        return "LoginWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        loader.startAnimation(nil)
        providerList.addItems(withTitles: Provider.getAllProvidersValues())
        
        self.window?.center()
        self.window?.orderFrontRegardless()
        self.window?.level = Int(CGWindowLevelForKey(.maximumWindow))
        
        NSApp.activate(ignoringOtherApps: true)
 
//        if preferences.hasLoggedAccount() {
//            self.window?.setIsVisible(false)
//        }
    }
    
    // MARK: - Private functions
    
    private func resetLoginForm() {
        providerList.selectItem(at: 0)
        usernameField.stringValue = ""
        passwordField.stringValue = ""
        infoLabel.stringValue = ""
    }
    
    // MARK: - IBAction
    
    @IBAction func login(_ sender: NSButton) {
        let username = usernameField.stringValue
        let password = passwordField.stringValue
        let selectedProvider = Provider.getProviderFromName(providerList.titleOfSelectedItem!)
        
        guard selectedProvider != nil && !username.isEmpty && !password.isEmpty else { return }
        
        sender.isEnabled = false
        loader.isHidden = false
        
        Service.fetchData(username, password: password, provider: selectedProvider!,
            failure: { error in
                sender.isEnabled = true
                self.loader.isHidden = true
                self.infoLabel.stringValue = error.errorDescription
                print(error)
            },
            success: { accountBalance in
                sender.isEnabled = true
                self.loader.isHidden = true
                self.resetLoginForm()
                
                self.delegate?.accountBalanceDidUpdate(accountBalance)
                self.window?.setIsVisible(false)
            }
        )
    }
}
