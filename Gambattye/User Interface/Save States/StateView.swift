//
//  StateView.swift
//  Gambattye
//
//  Created by Ben10do on 26/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

private let placeholderImage = NSImage(named: "No State")

class StateView: NSView {
    
    @IBOutlet var contentView: NSView?
    private(set) var selectedState: Int?
    dynamic private(set) var isStateSelected = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        NSNib(nibNamed: "StateView", bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil)
        addSubview(contentView!)
    }
    
    func setUpDisplay(romPath: URL) {
        let pathPrefix = romPath.deletingPathExtension().path
        
        for subview in contentView!.subviews {
            if let button = subview as? NSButton {
                if let image = StateImage(fromState: URL(fileURLWithPath: pathPrefix + "_\(button.tag).gqs"))?.toNSImage() {
                    button.image = image
                    button.isEnabled = true
                } else {
                    button.image = placeholderImage
                    button.isEnabled = false
                }
            }
        }
    }
    
    private func getState(num stateNum: Int) -> NSButton? {
        return viewWithTag(stateNum) as? NSButton
    }
    
    func setEnabled(_ enabled: Bool, forState stateNum: Int) {
        getState(num: stateNum)?.isEnabled = enabled
    }
    
    func setAllEnabled(_ enabled: Bool) {
        for subview in contentView!.subviews {
            if let button = subview as? NSButton {
                button.isEnabled = enabled
            }
        }
    }
    
    func setImage(_ theImage: NSImage?, forState stateNum: Int) {
        let image = theImage ?? placeholderImage
        getState(num: stateNum)?.image = image
    }
    
    @IBAction func buttonChanged(_ sender: NSButton) {
        guard sender.state == NSOnState else {
            sender.state = NSOnState
            return
        }
        
        for subview in contentView!.subviews {
            if let button = subview as? NSButton, button != sender {
                button.state = NSOffState
            }
        }
        
        selectedState = sender.tag
        isStateSelected = true
    }
    
}
