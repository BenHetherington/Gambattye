//
//  StateView.swift
//  Gambattye
//
//  Created by Ben Hetherington on 26/06/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

private let gbPlaceholderImage = #imageLiteral(resourceName: "No State (GB).png")
private let gbcPlaceholderImage = #imageLiteral(resourceName: "No State (GBC).png")

class StateView: NSView {
    
    @IBOutlet var contentView: NSView?
    private(set) var selectedState: Int?
    @objc dynamic private(set) var isStateSelected = false
    private weak var placeholderImage: NSImage?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        NSNib(nibNamed: NSNib.Name("StateView"), bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil)
        addSubview(contentView!)
    }
    
    func setUpDisplay(romPath: URL, console: Emulator.Console) {
        let pathPrefix = romPath.deletingPathExtension().path
        placeholderImage = console == .GB ? gbPlaceholderImage : gbcPlaceholderImage
        
        for subview in contentView!.subviews {
            if let button = subview as? NSButton {
                let url = URL(fileURLWithPath: pathPrefix + "_\(button.tag).gqs")
                if let image = StateImage(fromState: url)?.toNSImage() {
                    button.image = image
                    button.isEnabled = true
                } else {
                    button.image = placeholderImage
                    button.isEnabled = false
                }
                
                if let modifiedDate = (try? url.resourceValues(forKeys: [URLResourceKey.contentModificationDateKey]))?.contentModificationDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    dateFormatter.doesRelativeDateFormatting = true
                    button.toolTip = dateFormatter.string(from: modifiedDate)
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
        guard sender.state == .on else {
            sender.state = .on
            return
        }
        
        for subview in contentView!.subviews {
            if let button = subview as? NSButton, button != sender {
                button.state = .off
            }
        }
        
        selectedState = sender.tag
        isStateSelected = true
    }
    
}
