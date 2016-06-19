//
//  Service.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 14/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum AccountBalanceAPIError: ErrorType {
    case Unauthorized
    case Other(NSError)
}

class Service {
    static let BASE_URL = "https://api.clementgarbay.fr/accountbalance/" // "http://localhost:8125/"
    static let preferences = AppPreferences.sharedInstance
    
    static func fetchData(
        failure fail :      (AccountBalanceAPIError -> ())? = nil,
                success succeed:    (AccountBalance -> ())? = nil
        ) {
        
        if self.preferences.hasLoggedAccount() {
            let preferencesForRequest = self.preferences.getPreferencesForRequest()
            
            if preferencesForRequest != nil {
                let identifier = preferencesForRequest!["identifier"] as! String
                let password = preferencesForRequest!["password"] as! String
                let provider = preferencesForRequest!["provider"] as! Provider
                
                fetchData(identifier, password: password, provider: provider, failure: { error in
                    fail!(error)
                }) { accountBalance in
                    succeed!(accountBalance)
                }
            } else {
                fail!(AccountBalanceAPIError.Unauthorized)
            }
        } else {
            fail!(AccountBalanceAPIError.Unauthorized)
        }
    }
    
    static func fetchData(
        identifier:         String,
        password:           String,
        provider:           Provider,
        failure fail:       (AccountBalanceAPIError -> ())? = nil,
                success succeed:    (AccountBalance -> ())? = nil
        ) {
        
        let parameters: [String: AnyObject] = [
            "identifier" : identifier,
            "password" : password,
            "provider" : provider.rawValue
        ]
        
        Alamofire
            .request(.POST, BASE_URL, parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let response):
                    
                    let json = response as! [String: AnyObject]
                    let accountBalance = AccountBalance.fromJSON(json)
                    
                    // Save user informations
                    if !self.preferences.hasLoggedAccount() {
                        self.preferences.set(accountBalance.username, email: identifier, password: password, provider: provider)
                    }
                    
                    succeed!(accountBalance)
                case .Failure(let error):
                    let statusCode = error.userInfo["StatusCode"] as! Int
                    if statusCode == 401 {
                        fail!(AccountBalanceAPIError.Unauthorized)
                    } else {
                        fail!(AccountBalanceAPIError.Other(error))
                    }
                }
        }
    }
}