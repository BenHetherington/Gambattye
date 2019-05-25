//
//  Document.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class Document: NSDocument, NSWindowDelegate {

    @objc dynamic let emulator = Emulator()
    private let inputGetter = InputGetter()

    private var observers = [NSObjectProtocol]()

    @IBOutlet var gbWindow: GBWindow? {
        willSet {
            gbWindow?.delegate = nil
        }
        didSet {
            gbWindow?.makeFirstResponder(inputGetter)
            gbWindow?.delegate = self
        }
    }
    @IBOutlet var display: GBView?

    override init() {
        super.init()
        
        observers += NotificationCenter.default.addObserver(forName: .SaveState, object: nil, queue: nil) { [weak self] notification in
            if self?.gbWindow?.isMainWindow ?? false, let id = notification.userInfo?["id"] as? Int {
                self?.emulator.saveState(id: id)
            }
        }
        
        observers += NotificationCenter.default.addObserver(forName: .LoadState, object: nil, queue: nil) { [weak self] notification in
            if self?.gbWindow?.isMainWindow ?? false, let id = notification.userInfo?["id"] as? Int {
                self?.emulator.loadState(id: id)
            }
        }

        observers += NotificationCenter.default.addObserver(forName: .ConsoleChanged, object: emulator, queue: nil) { [weak self] _ in
            if #available(macOS 10.12.2, *), let gbWindow = self?.gbWindow, let emulator = self?.emulator {
                gbWindow.touchBarController?.console = emulator.console
            }
        }
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override class func canConcurrentlyReadDocuments(ofType _: String) -> Bool {
        return true
    }

    override var windowNibName: NSNib.Name? {
        // Returns the nib file name of the document
        return NSNib.Name("Document")
    }

    override func data(ofType typeName: String) throws -> Data {
        return emulator.romData
    }
    
    func render(dataProvider: CGDataProvider) {
        guard gbWindow?.occlusionState.contains(.visible) == true else {
            // Don't bother rendering if the window isn't visible
            return
        }

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).union([.byteOrder32Little])
        let image = CGImage(width: 160, height: 144, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 4 * 160, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)

        DispatchQueue.main.async { [weak self] in
            if let display = self?.display {
                display.image = image
            }
        }
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        emulator.renderer = { [weak self] dataProvider in
            self?.render(dataProvider: dataProvider)
        }

        try emulator.load(from: url)
        emulator.beginEmulation(inputGetter: inputGetter)
    }
    
    @IBAction func reset(_: Any?) {
        emulator.reset()
    }
    
    override var displayName: String! {
        get {
            // If possible, use the title in the ROM header
            return emulator.romTitle?.trimmingCharacters(in: .whitespaces) ?? super.displayName
        }
        set {
            super.displayName = newValue
        }
    }
    
    func windowDidResignMain(_: Notification) {
        if UserDefaults.standard.bool(forKey: "Autosave") {
            emulator.saveSaveData()
        }
    }
    
    func windowDidResignKey(_: Notification) {
        emulator.runWithLowLatency = false
    }
    
    func windowDidBecomeKey(_: Notification) {
        emulator.runWithLowLatency = true
        
        if #available(macOS 10.12.2, *) {
            _ = gbWindow?.makeTouchBar() // Without this, the touch bar may not exist (on startup)
            gbWindow?.touchBarController?.console = emulator.console
            // touchBarController.setUpDisplay() will be implicitly called
        }
    }
    
    @IBAction func goToSaveState(_: NSMenuItem) {
        let controller = SaveState()
        controller.console = emulator.console
        controller.romURL = fileURL
        gbWindow?.beginSheet(controller.window!) { [weak emulator] response in
            if response == .OK, let state = controller.stateView?.selectedState {
                emulator?.saveState(id: state)
            }
        }
    }
    
    @IBAction func goToLoadState(_: NSMenuItem) {
        let controller = LoadState()
        controller.console = emulator.console
        controller.romURL = fileURL
        gbWindow?.beginSheet(controller.window!) { [weak emulator] response in
            if response == .OK, let state = controller.stateView?.selectedState {
                emulator?.loadState(id: state)
            }
        }
    }

    func prepareForQuit() {
        emulator.saveSaveData()
    }
    
    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

}
