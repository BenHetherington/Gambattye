//
//  GeneralPreferencesViewController.swift
//  Gambattye
//
//  Created by Ben Hetherington on 08/04/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class GeneralPreferencesViewController: NSViewController, MASPreferencesViewController {

    let viewIdentifier = "GeneralPreferences"

    init() {
        super.init(nibName: NSNib.Name("GeneralPreferencesView"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var toolbarItemImage: NSImage? {
        return NSImage(named: NSImage.preferencesGeneralName)
    }
    
    var toolbarItemLabel: String? {
        return NSLocalizedString("General", comment: "Preferences Label")
    }
    
}
