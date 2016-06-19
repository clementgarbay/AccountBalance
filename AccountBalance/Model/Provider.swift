//
//  Provider.swift
//  AccountBalance
//
//  Created by Clément GARBAY on 14/06/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

enum Provider: Int, CustomStringConvertible {
    case Moneweb = 1
    case Melchior = 2
    
    var description: String {
        switch self {
        case .Moneweb:
            return "Moneweb (EMN)"
        case .Melchior:
            return "Melchior"
        }
    }
    
    var image: NSImage {
        switch self {
        case .Moneweb:
            return NSImage(named: "Moneweb-EMN")!
        case .Melchior:
            return NSImage(named: "Melchior")!
        }
    }
    
    static let allProviders = [Melchior, Moneweb]
    
    static func getAllProvidersValues() -> [String] {
        return Provider.allProviders
            .map { $0.description }
    }
    
    static func getProviderFromId(id: Int) -> Provider? {
        return allProviders
            .filter { $0.rawValue == id }
            .first
    }
    
    static func getProviderFromName(name: String) -> Provider? {
        return allProviders
            .filter { $0.description == name }
            .first
    }
}