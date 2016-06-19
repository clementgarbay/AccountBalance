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
    
    @IBOutlet weak var detailMenuItemView: DetailMenuItemView!
    @IBOutlet weak var refreshButton: NSMenuItem!
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
        
        detailMenuItemView.showMessageView("Rafraîchissement en cours...", messageType: MessageType.Info)
    }
    
    func showAccountBalanceInStatusItem(accountBalance: AccountBalance) {
        refreshButton.enabled = true
        refreshButton.hidden = false
        logoutButton.hidden = false

        statusItem.image = nil
        statusItem.title = accountBalance.currentBalance
        
        detailMenuItemView.showAccountView(accountBalance)
    }
    
    func clearAccountBalanceInStatusItem() {
        refreshButton.enabled = false
        refreshButton.hidden = true
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
                    if let message = error.userInfo["NSLocalizedDescription"] as? String {
                        self.detailMenuItemView.showMessageView(message, messageType: MessageType.Error)
                    } else {
                        self.detailMenuItemView.showMessageView("Erreur lors du rafraîchissement du solde", messageType: MessageType.Error)
                    }
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
        detailMenuItemView.showLoginView()
    }
    
    // MARK: - IBAction
    
    @IBAction func showLoginWindow(sender: NSButton) {
        showLoginWindow()
    }

    @IBAction func logout(sender: NSMenuItem) {
        // Clear saved preferences and reset app to the init state
        preferences.clear()
        clearAccountBalanceInStatusItem()
        detailMenuItemView.showLoginView()
        showLoginWindow()
    }
    
    @IBAction func refresh(sender: NSMenuItem) {
        updateAccountBalance()
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
