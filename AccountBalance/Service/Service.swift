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

enum RequestError: ErrorType {
    case Unauthorized
    case Other(NSError)
    
    static func fromNSError(error: NSError) -> RequestError {
        return error.userInfo["StatusCode"]
            .map({(e: AnyObject) -> Int in e as! Int})
            .map({ e in
                switch e {
                case 401:
                    return RequestError.Unauthorized
                default:
                    return RequestError.Other(error)
                }
            }) ?? RequestError.Other(error)
    }
}

class Service {
    static let BASE_URL = "https://api.clementgarbay.fr/accountbalance/" // "http://localhost:8125/"
    static let preferences = AppPreferences.sharedInstance
    
    static func fetchData(
        failure fail: (RequestError -> ())? = nil,
        success succeed: (AccountBalance -> ())? = nil
    ) {
        
        if self.preferences.hasLoggedAccount() {
            let preferencesForRequest = self.preferences.getPreferencesForRequest()
            
            if preferencesForRequest != nil {
                let email = preferencesForRequest!["email"] as! String
                let password = preferencesForRequest!["password"] as! String
                let provider = preferencesForRequest!["provider"] as! Provider
                
                fetchData(email, password: password, provider: provider, failure: { error in
                    fail!(error)
                }) { accountBalance in
                    succeed!(accountBalance)
                }
            } else {
                fail!(RequestError.Unauthorized)
            }
        } else {
            fail!(RequestError.Unauthorized)
        }
    }
    
    static func fetchData(
        email: String,
        password: String,
        provider: Provider,
        failure fail: (RequestError -> ())? = nil,
        success succeed: (AccountBalance -> ())? = nil
    ) {
        
        let parameters: [String: AnyObject] = [
            "identifier" : email,
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
                        self.preferences.set(accountBalance.username, email: email, password: password, provider: provider)
                    }
                    
                    succeed!(accountBalance)
                case .Failure(let error):
                    fail!(RequestError.fromNSError(error))
                }
        }
    }
}