//
//  GBView.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa

class GBView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer = CALayer()
        layer?.magnificationFilter = kCAFilterNearest
        layer?.isOpaque = true
    }
    
    override var layer: CALayer? {
        get {
            return super.layer
        }
        set {
            super.layer = newValue
        }
    }
    
    override var mouseDownCanMoveWindow: Bool {
        get {
            return true
        }
    }
    
    var image: CGImage? = nil {
        didSet {
            layer?.contents = image
        }
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return false
        }
    }
    
}