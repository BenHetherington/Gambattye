//
//  Application.swift
//  Gambattye
//
//  Created by Ben Hetherington on 14/10/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class Application: NSApplication {

    lazy var aboutPanelController = AboutPanelController()

    override func orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey: Any] = [:]) {
        aboutPanelController.orderFrontAboutPanel(options)
    }

}
