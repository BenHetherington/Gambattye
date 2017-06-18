//
//  KeyRecorderControl.swift
//  Gambattye
//
//  Created by Ben10do on 09/04/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import ShortcutRecorder

class KeyRecorderControl: SRRecorderControl {
    
    // TODO: See if we can mitigate this mess
    
    var name: String = "" {
        didSet {
            objectValue = UserDefaults.standard.dictionary(forKey: name + "ButtonKey")
        }
    }
    
    override var toolTip: String? {
        get {
            return nil
        }
        set {
            super.toolTip = nil
        }
    }
    
    override func view(_ view: NSView, stringForToolTip tag: NSToolTipTag, point: NSPoint, userData data: UnsafeMutableRawPointer?) -> String {
        let returnValue = super.view(view, stringForToolTip: tag, point: point, userData: data)
        if returnValue == SRLoc("Use old shortcut") {
            return NSLocalizedString("Use previous key", comment: "Controls Preferences")
        } else {
            return returnValue
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        let modifierFlags = event.modifierFlags.intersection(SRCocoaModifierFlagsMask)
        if isRecording && !modifierFlags.isEmpty { // Ignore the Fn key
            if areModifierFlagsValid(event.modifierFlags, forKeyCode: event.keyCode) {
                let newObjectValue: [AnyHashable: Any] = [SRShortcutKeyCode: event.keyCode,
                                                          SRShortcutModifierFlagsKey: modifierFlags.rawValue,
                                                          SRShortcutCharacters: 0,
                                                          SRShortcutCharactersIgnoringModifiers: 0]
                
                endRecording(withObjectValue: newObjectValue)
            }
        }
    }
    
    override func clearAndEndRecording() {
        // All controls should be assigned, so don't let this happen
    }
    
    override func clearButtonRect() -> NSRect {
        return NSRect(x: bounds.maxX - 4.0 - 1.0,
                      y: bounds.minY,
                      width: 0.0,
                      height: 25.0)
    }
    
}
