//
//  AppPreferences.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 14/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Foundation
import KeychainSwift

class AppPreferences {
    
    static let sharedInstance = AppPreferences()
    
    private let preferences = UserDefaults.standard
    private let keychain = KeychainSwift()
    
    private init() {}
    
    /**
     Checks if an account is logged.
     
     - Returns: True if an account is logged, false otherwise.
     */
    func hasLoggedAccount() -> Bool {
        return self.preferences.bool(forKey: "hasLoggedAccount") && self.keychain.get("AccountBalance") != nil
    }
    
    /**
     Set preferences.
     
     - Parameter username:  The string of the username of the account.
     - Parameter email:     The string of the email for the login.
     - Parameter password:  The string of the password for the login.
     - Parameter provider:  The corresponding Provider.
     */
    func set(_ username: String, email: String, password: String, provider: Provider) {
        preferences.set(true, forKey: "hasLoggedAccount")
        preferences.setValue(username, forKey: "username")
        preferences.setValue(email, forKey: "email")
        preferences.set(provider.rawValue, forKey: "provider")
        // TODO : encrypt it with public key
        keychain.set(password, forKey: "AccountBalance")
    }
    
    /**
     Get the username corresponding to the logged account.
     
     - Returns: The string of the username.
     */
    func getUsernameOfLoggedAccount() -> String? {
        if hasLoggedAccount() {
            return self.preferences.value(forKey: "username") as? String
        }
        
        return nil
    }
    
    /**
     Get the preferences useful for request API.
     
     - Returns: A dictionary of preferences.
     */
    func getPreferencesForRequest() -> [String: Any]? {
        
        guard let email = self.preferences.value(forKey: "email") as? String else { return nil }
        guard let password = self.keychain.get("AccountBalance") else { return nil }
        guard let provider = Provider.getProviderFromId(self.preferences.integer(forKey: "provider")) else { return nil }
        guard hasLoggedAccount() else { return nil }
        
        var pref = [String: Any]()
        pref["email"] = email
        pref["password"] = password
        pref["provider"] = provider
        
        return pref
    }
    
    /**
     Remove all preferences.
     */
    func clear() {
        let appDomain = Bundle.main.bundleIdentifier!
        preferences.removePersistentDomain(forName: appDomain)
        keychain.clear()
    }
    
    // MARK: - Getters
    
    func getProvider() -> Provider {
        return Provider.getProviderFromId(self.preferences.integer(forKey: "provider"))!
    }
    
}
