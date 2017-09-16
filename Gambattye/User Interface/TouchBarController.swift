//
//  TouchBarController.swift
//  Gambattye
//
//  Created by Ben10do on 29/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

@available(macOS 10.12.2, *)
class TouchBarController: NSObject {
    
    @IBOutlet var touchBar: NSTouchBar?
    @IBOutlet var descriptionText: NSTextField?
    @IBOutlet var swapText: NSTextField?
    var buttons = [NSButton?]()
    
    @IBOutlet var button0: NSButton?
    @IBOutlet var button1: NSButton?
    @IBOutlet var button2: NSButton?
    @IBOutlet var button3: NSButton?
    @IBOutlet var button4: NSButton?
    @IBOutlet var button5: NSButton?
    @IBOutlet var button6: NSButton?
    @IBOutlet var button7: NSButton?
    @IBOutlet var button8: NSButton?
    @IBOutlet var button9: NSButton?
    
    var romURL: URL? {
        didSet {
            setUpDisplay()
        }
    }
    private(set) var shouldSave = false
    
    var saveState: ((Int) -> Void)?
    var loadState: ((Int) -> Void)?
    
    private let placeholderImage = NSImage(named: NSImage.Name("No State"))
    private var optionPressedObserver: NSObjectProtocol?
    private var optionReleasedObserver: NSObjectProtocol?
    private var stateSavedObserver: NSObjectProtocol?

    override init() {
        super.init()
        NSNib(nibNamed: NSNib.Name("Touch Bar"), bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil)
        buttons = [button0, button1, button2, button3, button4, button5, button6, button7, button8, button9]
        setUpDisplay()
        
        optionPressedObserver = NotificationCenter.default.addObserver(forName: .OptionPressed, object: nil, queue: nil) { [weak self] _ in
            self?.shouldSave = true
            self?.setUpDisplay()
        }
        
        optionReleasedObserver = NotificationCenter.default.addObserver(forName: .OptionReleased, object: nil, queue: nil) { [weak self] _ in
            self?.shouldSave = false
            self?.setUpDisplay()
        }
        
        stateSavedObserver = NotificationCenter.default.addObserver(forName: .SaveState, object: nil, queue: nil) { [weak self] _ in
            self?.setUpDisplay()
        }
    }
    
    func setUpDisplay() {
        let pathPrefix = romURL?.deletingPathExtension().path
        
        for button in buttons {
            if let pathPrefix = pathPrefix, let image = StateImage(fromState: URL(fileURLWithPath: pathPrefix + "_\(button!.tag).gqs"))?.toNSImage() {
                button?.image = image
                button?.isEnabled = true
            } else {
                button?.image = placeholderImage
                button?.isEnabled = false
            }
        }
        
        if shouldSave {
            descriptionText?.stringValue = NSLocalizedString("Save State:", comment: "Touch Bar Title")
            swapText?.stringValue = NSLocalizedString("Release ⌥ to load.", comment: "Touch Bar Subtitle")
            setAllAction(#selector(saveState(_:)))
            setAllEnabled(true)
        } else {
            descriptionText?.stringValue = NSLocalizedString("Restore State:", comment: "Touch Bar Title")
            swapText?.stringValue = NSLocalizedString("Hold ⌥ to save.", comment: "Touch Bar Subtitle")
            setAllAction(#selector(loadState(_:)))
        }
    }
    
    func setAllEnabled(_ enabled: Bool) {
        for button in buttons {
            button?.isEnabled = enabled
        }
    }
    
    func setAllAction(_ action: Selector?) {
        for button in buttons {
            button?.action = action
        }
    }
    
    @IBAction func saveState(_ sender: NSButton) {
        NotificationCenter.default.post(name: .SaveState, object: self, userInfo: ["id": sender.tag])
    }
    
    @IBAction func loadState(_ sender: NSButton) {
        NotificationCenter.default.post(name: .LoadState, object: self, userInfo: ["id": sender.tag])
    }
    
    deinit {
        if let optionPressedObserver = optionPressedObserver, let optionReleasedObserver = optionReleasedObserver, let stateSavedObserver = stateSavedObserver {
            NotificationCenter.default.removeObserver(optionPressedObserver)
            NotificationCenter.default.removeObserver(optionReleasedObserver)
            NotificationCenter.default.removeObserver(stateSavedObserver)
        }
    }
    
}
