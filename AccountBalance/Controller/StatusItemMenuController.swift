//
//  StatusItemMenuController.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 15/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

class StatusItemMenuController: NSObjectController, AccountBalanceDelegate {
    
    @IBOutlet weak var statusItemMenu: NSMenu!
    
    @IBOutlet weak var accountView: AccountView!
    @IBOutlet weak var refreshButton: NSMenuItem!
    @IBOutlet weak var loginButton: NSMenuItem!
    @IBOutlet weak var logoutButton: NSMenuItem!
    
    private var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    private let statusIcon = NSImage(named: "StatusItemMenuIcon")!
    private let refreshIcon = NSImage(named: "RefreshIcon")!
    
    private var loginWindowController: LoginWindowController!
    private let preferences = AppPreferences.sharedInstance
    
    override func awakeFromNib() {
        // for dark mode
        statusIcon.template = true
        refreshIcon.template = true
        
        statusItem.image = statusIcon
        statusItem.menu = statusItemMenu
    
        loginWindowController = LoginWindowController()
        loginWindowController.delegate = self
        
        updateAccountBalance()
    }
    
    // MARK: - Protocol function
    
    func accountBalanceDidUpdate(accountBalance: AccountBalance) {
        showAccountBalanceInStatusItem(accountBalance)
    }
    
    // MARK: - Functions used to modify status item
    
    func showRefreshImageInStatusItem() {
        refreshButton.enabled = false
        statusItem.title = ""
        statusItem.image = refreshIcon
    }
    
    func showAccountBalanceInStatusItem(accountBalance: AccountBalance) {
        refreshButton.enabled = true
        refreshButton.hidden = false
        loginButton.hidden = true
        logoutButton.hidden = false

        statusItem.image = nil
        statusItem.title = accountBalance.currentBalance
        
        accountView.update(accountBalance)
    }
    
    func clearAccountBalanceInStatusItem() {
        refreshButton.enabled = false
        refreshButton.hidden = true
        loginButton.hidden = false
        logoutButton.hidden = true
        
        statusItem.title = ""
        statusItem.image = statusIcon
    }
    
    // MARK: - Private functions
    
    private func updateAccountBalance() {
        showRefreshImageInStatusItem()
        
        Service.fetchData(
            failure: { error in
                self.statusItem.image = self.statusIcon
                
                switch error {
                case .Unauthorized:
                    self.showLoginWindow()
                case .Other(let error):
                    print(error)
                }
            },
            success: { accountBalance in
                self.showAccountBalanceInStatusItem(accountBalance)
            }
        )
    }
    
    private func showLoginWindow() {
        loginWindowController.showWindow(nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func showLoginWindow(sender: NSMenuItem) {
        showLoginWindow()
    }

    @IBAction func logout(sender: NSMenuItem) {
        // Clear saved preferences and reset app to the init state
        preferences.clear()
        clearAccountBalanceInStatusItem()
        showLoginWindow()
    }
    
    @IBAction func refresh(sender: NSMenuItem) {
        updateAccountBalance()
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
