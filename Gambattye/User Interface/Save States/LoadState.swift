//
//  LoadState.swift
//  Gambattye
//
//  Created by Ben Hetherington on 26/06/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class LoadState: NSWindowController {
    
    @IBOutlet weak var stateView: StateView?
    @IBOutlet weak var okButton: NSButton?
    
    var romURL: URL? {
        didSet {
            if let romURL = romURL {
                stateView?.setUpDisplay(romPath: romURL, console: console)
            }
        }
    }
    var console: Emulator.Console = .GBC {
        didSet {
            if let romURL = romURL {
                stateView?.setUpDisplay(romPath: romURL, console: console)
            }
        }
    }
    
    override var windowNibName: NSNib.Name {
        return NSNib.Name("LoadState")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let romURL = romURL {
            stateView?.setUpDisplay(romPath: romURL, console: console)
        }
        
        for subview in stateView!.contentView!.subviews {
            if let button = subview as? DoubleClickButton {
                button.doubleClickAction = { [weak self] button in
                    self?.ok(button)
                }
            }
        }
    }
        
    @IBAction func cancel(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
    }
    
    @IBAction func ok(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
    }
    
}
