//
//  DoubleClickButton.swift
//  Gambattye
//
//  Created by Ben10do on 28/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class DoubleClickButton: NSButton {
    
    var doubleClickAction: ((NSButton) -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount >= 2, let doubleClickAction = doubleClickAction {
            doubleClickAction(self)
        } else {
            super.mouseDown(with: event)
        }
    }
    
}
