//
//  GeneralPreferencesViewController.swift
//  Gambattye
//
//  Created by Ben10do on 08/04/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa
import MASPreferences

class GeneralPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    init() {
        super.init(nibName: "GeneralPreferencesView", bundle: nil)!
        identifier = "GeneralPreferences"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: NSImageNamePreferencesGeneral)
    }
    
    var toolbarItemLabel: String! {
        return "General"
    }
    
}
