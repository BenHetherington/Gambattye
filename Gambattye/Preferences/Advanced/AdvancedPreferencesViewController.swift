//
//  AdvancedPreferencesViewController.swift
//  Gambattye
//
//  Created by Ben10do on 26/09/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import MASPreferences

class AdvancedPreferencesViewController: NSViewController, MASPreferencesViewController {

    @IBOutlet var gbRomPathControl: NSPathControl?

    init() {
        super.init(nibName: NSNib.Name("AdvancedPreferencesView"), bundle: nil)
        identifier = NSUserInterfaceItemIdentifier("AdvancedPreferences")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var toolbarItemImage: NSImage? {
        return NSImage(named: .advanced)
    }

    var toolbarItemLabel: String? {
        return NSLocalizedString("Advanced", comment: "Preferences Label")
    }

    @IBAction func resetOriginalGBRom(_: NSButton) {
        NSUserDefaultsController.shared.defaults.removeObject(forKey: "OriginalGBBootROM")
    }

    @IBAction func bootRomPathControlClicked(sender: NSPathControl) {
        guard let window = view.window else {
            return
        }

        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["", "bin"]
        openPanel.beginSheetModal(for: window) { (result) in
            guard result == .OK else {
                return
            }

            sender.url = openPanel.url
            UserDefaults.standard.set(sender.url, forKey: "OriginalGBBootROM")
        }
    }
    
}
