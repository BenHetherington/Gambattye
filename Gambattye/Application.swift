//
//  Application.swift
//  Gambattye
//
//  Created by Ben10do on 14/10/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class Application: NSApplication {

    lazy var aboutPanelController = AboutPanelController()

    override func orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey: Any] = [:]) {
        if aboutPanelController.appearance == nil {
            aboutPanelController.appearance = NSAppearance(named: .vibrantDark)
        }
        aboutPanelController.orderFrontAboutPanel(options)
    }

}
