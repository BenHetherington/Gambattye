//
//  SaveState.swift
//  Gambattye
//
//  Created by Ben10do on 28/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class SaveState: LoadState {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        stateView?.setAllEnabled(true)
        okButton?.title = NSLocalizedString("Save State", comment: "OK Button in Save State Dialog")
    }
    
}
