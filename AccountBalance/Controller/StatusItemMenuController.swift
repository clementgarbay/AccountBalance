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
    
    private var statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    private let statusIcon = NSImage(named: "StatusItemMenuIcon")!
    private let refreshIcon = NSImage(named: "RefreshIcon")!
    
    private var loginWindowController: LoginWindowController!
    private let preferences = AppPreferences.sharedInstance
    
    override func awakeFromNib() {
        // for dark mode
        statusIcon.isTemplate = true
        refreshIcon.isTemplate = true
        
        statusItem.image = statusIcon
        statusItem.menu = statusItemMenu
    
        loginWindowController = LoginWindowController()
        loginWindowController.delegate = self
        
        updateAccountBalance()
    }
    
    // MARK: - Protocol function
    
    func accountBalanceDidUpdate(_ accountBalance: AccountBalance) {
        showAccountBalanceInStatusItem(accountBalance)
    }
    
    // MARK: - Functions used to modify status item
    
    func showRefreshImageInStatusItem() {
        refreshButton.isEnabled = false
        statusItem.title = ""
        statusItem.image = refreshIcon
        
        detailMenuItemView.showMessageView("Rafraîchissement en cours...", messageType: .info)
    }
    
    func showAccountBalanceInStatusItem(_ accountBalance: AccountBalance) {
        refreshButton.isEnabled = true
        refreshButton.isHidden = false
        logoutButton.isHidden = false

        statusItem.image = nil
        statusItem.title = accountBalance.currentBalance
        
        detailMenuItemView.showAccountView(accountBalance)
    }
    
    func clearAccountBalanceInStatusItem() {
        refreshButton.isEnabled = false
        refreshButton.isHidden = true
        logoutButton.isHidden = true
        
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
                case .unauthorized:
                    self.showLoginWindow()
                default:
                    self.detailMenuItemView.showMessageView(error.errorDescription, messageType: .error)
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
    
    @IBAction func showLoginWindow(_ sender: NSButton) {
        showLoginWindow()
    }

    @IBAction func logout(_ sender: NSMenuItem) {
        // Clear saved preferences and reset app to the init state
        preferences.clear()
        clearAccountBalanceInStatusItem()
        detailMenuItemView.showLoginView()
        showLoginWindow()
    }
    
    @IBAction func refresh(_ sender: NSMenuItem) {
        updateAccountBalance()
    }
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
}
