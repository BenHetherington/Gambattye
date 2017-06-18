//
//  PreferencesWindowController.swift
//  Gambattye
//
//  Created by Ben10do on 08/04/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class PreferencesWindowController: MASPreferencesWindowController {

    init() {
        super.init(viewControllers: [GeneralPreferencesViewController(),
                                     ControlPreferencesViewController()],
                   title: NSLocalizedString("Preferences", comment: "Preferences Title"))
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
