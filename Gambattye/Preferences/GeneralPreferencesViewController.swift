//
//  GeneralPreferencesViewController.swift
//  Gambattye
//
//  Created by Ben10do on 08/04/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class GeneralPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    init() {
        super.init(nibName: NSNib.Name("GeneralPreferencesView"), bundle: nil)
        identifier = NSUserInterfaceItemIdentifier("GeneralPreferences")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var toolbarItemImage: NSImage? {
        return NSImage(named: .preferencesGeneral)
    }
    
    var toolbarItemLabel: String? {
        return NSLocalizedString("General", comment: "Preferences Label")
    }
    
}
