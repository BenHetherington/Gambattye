//
//  AppDelegate.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var preferences = PreferencesWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let defaultsURL = Bundle.main.url(forResource: "Defaults", withExtension: "plist"),
        let defaults = NSDictionary(contentsOf: defaultsURL) as? [String : Any] {
            UserDefaults.standard.register(defaults: defaults)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for document in NSDocumentController.shared().documents {
            if let document = document as? Document {
                document.saveSaveData()
            }
        }
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        NSDocumentController.shared().openDocument(nil)
        return false
    }
    
    @IBAction func showPreferences(_ sender: NSView) {
        preferences.showWindow(nil)
    }
    
}

