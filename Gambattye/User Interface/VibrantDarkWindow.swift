//
//  VibrantDarkWindow.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

@IBDesignable class VibrantDarkWindow: NSWindow {

    override func awakeFromNib() {
        super.awakeFromNib()
        appearance = appearance ?? NSAppearance(named: .vibrantDark)
    }

}
