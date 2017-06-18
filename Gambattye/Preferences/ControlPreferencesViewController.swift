//
//  ControlPreferencesViewController.swift
//  Gambattye
//
//  Created by Ben10do on 09/04/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class ControlPreferencesViewController: NSViewController, MASPreferencesViewController {

    init() {
        super.init(nibName: "ControlPreferencesView", bundle: nil)!
        identifier = "ControlPreferences"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: NSImageNameAdvanced)
    }
    
    var toolbarItemLabel: String! {
        return NSLocalizedString("Controls", comment: "Preferences Label")
    }
    
}
