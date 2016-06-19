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
        
        providerList.addItemsWithTitles(Provider.getAllProvidersValues())
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        
//        if preferences.hasLoggedAccount() {
//            self.window?.setIsVisible(false)
//        }
    }
    
    // MARK: - Private functions
    
    private func resetLoginForm() {
        providerList.selectItemAtIndex(0)
        usernameField.stringValue = ""
        passwordField.stringValue = ""
        infoLabel.stringValue = ""
    }
    
    // MARK: - IBAction
    
    @IBAction func login(sender: NSButton) {
        let username = usernameField.stringValue
        let password = passwordField.stringValue
        let selectedProvider = Provider.getProviderFromName(providerList.titleOfSelectedItem!)
        
        guard selectedProvider != nil && !username.isEmpty && !password.isEmpty else { return }
        
        sender.enabled = false
        loader.hidden = false
        
        Service.fetchData(username, password: password, provider: selectedProvider!,
            failure: { error in
                sender.enabled = true
                self.loader.hidden = true
                            
                switch error {
                case .Unauthorized:
                    self.infoLabel.stringValue = "Identifiant ou mot de passe incorrect"
                case .Other(_):
                    self.infoLabel.stringValue = "Une erreur est survenue"
                }
            },
            success: { accountBalance in
                sender.enabled = true
                self.loader.hidden = true
                self.resetLoginForm()
                
                self.delegate?.accountBalanceDidUpdate(accountBalance)
                self.window?.setIsVisible(false)
            }
        )
    }
}
