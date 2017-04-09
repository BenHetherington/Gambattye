//
//  InputGetter.swift
//  Gambattye
//
//  Created by Ben10do on 30/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa

let defaultKeyToButton = ["Up": Buttons.up, "Down": .down, "Left": .left, "Right": .right, "A": .A, "B": .B, "Select": .select, "Start": .start]

let modiferKeyToFlag: [UInt16: NSEventModifierFlags] = [54: .command, 55: .command, 56: .shift, 58: .option, 59: .control, 60: .shift, 61: .option, 62: .control]

class InputGetter: NSResponder, InputGetterProtocol {
    var keyboardPushedButtons = Buttons()
    var persistPushedButtons = Buttons()
    
    var keyToButton = [UInt16: Buttons]()
    var modifierFlagToButton = [UInt: Buttons]()
    
    override init() {
        super.init()
        setKeys()
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.setKeys()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setKeys()
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.setKeys()
        }
    }
    
    private func setKeys() {
        keyToButton.removeAll()
        modifierFlagToButton.removeAll()
        
        for (key, button) in defaultKeyToButton {
            let shortcut = UserDefaults.standard.dictionary(forKey: key + "ButtonKey")!
            
            if let keyCode = shortcut["keyCode"] as? UInt16 {
                keyToButton[keyCode] = button
            }
            if let modifierKey = shortcut["modifierFlags"] as? UInt {
                modifierFlagToButton[modifierKey] = button
            }
        }
    }
    
    public func getInput() -> Buttons {
        return keyboardPushedButtons.union(persistPushedButtons)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
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
        if let flag = modiferKeyToFlag[event.keyCode], let button = modifierFlagToButton[flag.rawValue] {
            if event.modifierFlags.contains(flag) {
                keyboardPushedButtons.insert(button)
            } else {
                keyboardPushedButtons.remove(button)
            }
        } else {
            super.flagsChanged(with: event)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
