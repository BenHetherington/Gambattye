//
//  PreferencesWindowController.swift
//  Gambattye
//
//  Created by Ben Hetherington on 08/04/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class PreferencesWindowController: MASPreferencesWindowController {

    init(_: ()) {
        if !ValueTransformer.valueTransformerNames().contains(NSValueTransformerName(rawValue: "UrlStorage")) {
            ValueTransformer.setValueTransformer(UrlStorage(), forName: NSValueTransformerName(rawValue: "UrlStorage"))
        }

        super.init(viewControllers: [GeneralPreferencesViewController(),
                                     ControlPreferencesViewController(),
                                     AdvancedPreferencesViewController()],
                   title: NSLocalizedString("Preferences", comment: "Preferences Title"))
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
