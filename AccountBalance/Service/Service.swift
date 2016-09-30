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

enum RequestError: Error {
    case unauthorized
    case notFound
    case other(AFError)
    
    var errorDescription: String {
        switch self {
        case .unauthorized:
            return "Identifiant ou mot de passe incorrect"
        case .notFound:
            return "Serveur non trouvé"
        case .other(let error):
            if let message = error.errorDescription {
                return message
            }
            return "Erreur lors du l'appel au serveur"
        }
    }
    
    static func fromAFError(_ error: AFError) -> RequestError {
        switch error {
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                switch code {
                case 401:
                    return RequestError.unauthorized
                case 404:
                    return RequestError.notFound
                default:
                    return RequestError.other(error)
                }
            default:
                return RequestError.other(error)
            }
        default:
            return RequestError.other(error)
        }
    }
}

class Service {
    static let BASE_URL = "https://api.clementgarbay.fr/accountbalance/" // "http://localhost:8125/"
    static let preferences = AppPreferences.sharedInstance
    
    static func fetchData(
        failure fail: ((RequestError) -> ())? = nil,
        success succeed: ((AccountBalance) -> ())? = nil
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
                fail!(RequestError.unauthorized)
            }
        } else {
            fail!(RequestError.unauthorized)
        }
    }
    
    static func fetchData(
        _ email: String,
        password: String,
        provider: Provider,
        failure fail: ((RequestError) -> ())? = nil,
        success succeed: ((AccountBalance) -> ())? = nil
    ) {
        
        let parameters: [String: Any] = [
            "identifier" : email,
            "password" : password,
            "provider" : provider.rawValue
        ]
      
        Alamofire
            .request(BASE_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let response):
                    
                    let json = response as! [String: AnyObject]
                    let accountBalance = AccountBalance.fromJSON(json)
                    
                    // Save user informations
                    if !self.preferences.hasLoggedAccount() {
                        self.preferences.set(accountBalance.username, email: email, password: password, provider: provider)
                    }
                    
                    succeed!(accountBalance)
                case .failure(let error):
                    fail!(RequestError.fromAFError(error as! AFError))
                }
        }
    }
}
