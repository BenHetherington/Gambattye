//
//  AdvancedPreferencesViewController.swift
//  Gambattye
//
//  Created by Ben Hetherington on 26/09/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class AdvancedPreferencesViewController: NSViewController, MASPreferencesViewController {

    @IBOutlet var gbRomPathControl: NSPathControl?

    let viewIdentifier = "AdvancedPreferences"

    init() {
        super.init(nibName: NSNib.Name("AdvancedPreferencesView"), bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var toolbarItemImage: NSImage? {
        return NSImage(named: NSImage.advancedName)
    }

    var toolbarItemLabel: String? {
        return NSLocalizedString("Advanced", comment: "Preferences Label")
    }

    @IBAction func resetOriginalGBRom(_: NSButton) {
        NSUserDefaultsController.shared.defaults.removeObject(forKey: "OriginalGBBootROM")
    }

    @IBAction func resetGBCRom(_: NSButton) {
        NSUserDefaultsController.shared.defaults.removeObject(forKey: "GBCBootROM")
    }

    @IBAction func bootRomPathControlClicked(sender: NSPathControl) {
        guard let window = view.window else {
            return
        }
        let isGBC = sender.tag == 1

        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["", "bin", isGBC ? "gbc" : "gb"]
        openPanel.beginSheetModal(for: window) { result in
            guard result == .OK else {
                return
            }

            sender.url = openPanel.url
            UserDefaults.standard.set(sender.url, forKey: isGBC ? "GBCBootROM" : "OriginalGBBootROM")
        }
    }
    
}
