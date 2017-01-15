//
//  AppDelegate.swift
//  AccountBalanceLauncher
//
//  Created by Clément GARBAY on 07/10/2016.
//  Copyright © 2016 Clément GARBAY. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let launcherAppIdentifier = "fr.clementgarbay.AccountBalanceLauncher"
        
        SMLoginItemSetEnable(launcherAppIdentifier, true)
        
        var startedAtLogin = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
            }
        }
        
        if startedAtLogin {
            DistributedNotificationCenter.default().post(name: "killme", object: Bundle.main.bundleIdentifier!)
        }
    }

}

