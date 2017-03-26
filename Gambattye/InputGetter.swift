//
//  InputGetter.swift
//  Gambattye
//
//  Created by Ben10do on 30/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa

class InputGetter: NSResponder, InputGetterProtocol {
    var keyboardPushedButtons = Buttons()
    var persistPushedButtons = Buttons()
    var keyToButton: [UInt16: Buttons] = [126 : .up,     // Up key
                                          125 : .down,   // Down key
                                          123 : .left,   // Left key
                                          124 : .right,  // Right key
                                          1   : .A,      // S key
                                          0   : .B,      // A key
                                          56  : .select, // Left shift key
                                          60  : .select, // Right shift key
                                          36  : .start]  // Enter key
    var modiferKeyToFlag: [UInt16: NSEventModifierFlags] = [56 : .shift, 60 : .shift]
    
    public func getInput() -> Buttons {
        return keyboardPushedButtons.union(persistPushedButtons)
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let button = keyToButton[event.keyCode] {
            if !event.isARepeat {
                keyboardPushedButtons.insert(button)
            }
        } else {
            super.keyDown(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let button = keyToButton[event.keyCode] {
            keyboardPushedButtons.remove(button)
        } else {
            super.keyUp(with: event)
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        if let button = keyToButton[event.keyCode], let flag = modiferKeyToFlag[event.keyCode] {
            if event.modifierFlags.contains(flag) {
                keyboardPushedButtons.insert(button)
            } else {
                keyboardPushedButtons.remove(button)
            }
        } else {
            super.flagsChanged(with: event)
        }
    }

}
