//
//  AccountBalance.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 14/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Foundation

struct AccountBalance {
    var username: String
    var currentBalance: String
    var history: [[String: String]]
    
    static func fromJSON(_ json: [String: AnyObject]) -> AccountBalance {
        let username = json["username"] as! String
        let currentBalance = json["currentBalance"] as! String
        let history = json["history"] as? [[String: String]] ?? []
        
        return AccountBalance(username: username, currentBalance: currentBalance, history: history)
    }
}
