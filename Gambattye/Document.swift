//
//  Document.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

private let expectedSamples = 35112
private let frameRate = 262144.0 / 4389.0

private let soundEnabledAttributeKey = "com.ben10do.Gambattye.SoundEnabled"
private let consoleAttributeKey = "com.ben10do.Gambattye.Console"

class Document: NSDocument, NSWindowDelegate {
    
    private var romData = Data()
    private let emulator = GB()
    private var timer = DispatchSource.makeTimerSource()
    private let inputGetter = InputGetter()
    private let audioEngine: AudioEngine?
    private var internalSoundEnabled = true
    private let emulationStateAccessQueue = DispatchQueue(label: "com.ben10do.Gambattye.EmulationStateAccess")
    private var notificationTimer: Timer?
    
    private var videoBuffer = [UInt32](repeating: 0xF8F8F8, count: 160 * 144)
    private var dataProvider: CGDataProvider?
    
    private var audioBuffer = [UInt32](repeating: 0, count: expectedSamples + 2064)
    
    private var shouldReschedule = false
    private var frameDivisor = 4
    
    private var loadFlags: LoadFlags = []
    private var keyToConsole = ["consoleIsGB": Console.GB, "consoleIsGBC": .GBC, "consoleIsGBA": .GBA]
    
    private var saveStateObserver: NSObjectProtocol?
    private var loadStateObserver: NSObjectProtocol?
    
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
        do {
            try audioEngine = AudioEngine()
        } catch {
            Swift.print(error.localizedDescription)
            audioEngine = nil
            internalSoundEnabled = false
        }
        
        super.init()
        
        saveStateObserver = NotificationCenter.default.addObserver(forName: .SaveState, object: nil, queue: nil) { [weak self] notification in
            if self?.gbWindow?.isMainWindow ?? false, let id = notification.userInfo?["id"] as? Int {
                self?.saveState(id: id)
            }
        }
        
        loadStateObserver = NotificationCenter.default.addObserver(forName: .LoadState, object: nil, queue: nil) { [weak self] notification in
            if self?.gbWindow?.isMainWindow ?? false, let id = notification.userInfo?["id"] as? Int {
                self?.loadState(id: id)
            }
        }
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        return "Document"
    }

    override func data(ofType typeName: String) throws -> Data {
        return romData
    }
    
    func beginEmulation() {
        emulator.setInputGetter(inputGetter)
        soundEnabled = fileURL?.getExtendedAttribute(name: soundEnabledAttributeKey) ?? true
        rescheduleTimer(forStart: true)
        
        dataProvider = CGDataProvider(data: Data(bytesNoCopy: &videoBuffer, count: 4 * videoBuffer.count, deallocator: .none) as CFData)!
        
        let dispatchHandler = DispatchWorkItem { [weak self] in
            self?.emulate()
        }
        
        timer.setEventHandler(handler: dispatchHandler)
        
        if #available(OSX 10.12, *) {
            timer.activate()
        } else {
            // Fallback on earlier versions
            timer.resume()
        }
    }
    
    func emulate() {
        var samples = expectedSamples / frameDivisor
        
        var result = 0
        emulationStateAccessQueue.sync {
            result = emulator.run(withVideoBuffer: &videoBuffer, pitch: 160, audioBuffer: &audioBuffer, samples: &samples)
            
            if internalSoundEnabled, let audioEngine = audioEngine {
                audioEngine.pushData(newData: audioBuffer, count: samples)
            }
        }
            
        if result != -1 {
            if shouldReschedule {
                shouldReschedule = false
                rescheduleTimer(forStart: false)
            }
            
            if gbWindow?.occlusionState.contains(.visible) == true {
                // Don't bother rendering if the window isn't visible
                render()
            }
        }
    }
    
    func render() {
        if let dataProvider = dataProvider {
            let image = CGImage(width: 160, height: 144, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 4 * 160, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: [], provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
            
            DispatchQueue.main.async { [weak self] in
                if let display = self?.display {
                    display.image = image
                }
            }
        }
    }
    
    private func rescheduleTimer(forStart: Bool) {
        frameDivisor = (gbWindow?.isKeyWindow ?? false) ? 4 : 1
        let leeway = DispatchTimeInterval.milliseconds((gbWindow?.isKeyWindow ?? false) ? 1 : 5)
        let interval = 1 / (frameRate * Double(frameDivisor))
        let startTime = DispatchTime.now().uptimeNanoseconds + (forStart ? 100000000 : UInt64(interval * 1e9))
        timer.scheduleRepeating(deadline: DispatchTime(uptimeNanoseconds: startTime), interval: interval, leeway: leeway)
    }
    
    func saveSaveData() {
        emulationStateAccessQueue.sync {
            emulator.saveSaveData()
        }
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        try romData = Data(contentsOf: url) // Just in case someone tries to save the ROM
        console = fileURL?.getExtendedAttribute(name: consoleAttributeKey) ?? .GBC
        
        try emulator.load(from: url, flags: loadFlags)
        beginEmulation()
    }
    
    @IBAction func reset(_: Any?) {
        emulationStateAccessQueue.sync {
            emulator.reset()
            audioEngine?.restartAudio()
        }
    }
    
    dynamic var soundEnabled: Bool {
        get {
            return internalSoundEnabled && canEnableSound
        }
        set {
            if canEnableSound {
                do {
                    if newValue {
                        try audioEngine?.startAudio()
                    } else {
                        audioEngine?.stopAudio()
                    }
                    
                    internalSoundEnabled = newValue
                    fileURL?.setExtendedAttribute(name: soundEnabledAttributeKey, value: newValue)
                    
                } catch {
                    NSAlert(error: error).runModal()
                    internalSoundEnabled = false
                }
            }
        }
    }
    
    dynamic var canEnableSound: Bool {
        return audioEngine != nil
    }
    
    enum Console: UInt8 {
        case GB, GBC, GBA
    }
    
    var console: Console = .GBC {
        didSet {
            for key in keyToConsole.keys {
                willChangeValue(forKey: key)
            }
            
            switch console {
            case .GB:
                loadFlags = loadFlags.union(.forceDMG).subtracting(.useGBA)
                
            case .GBC:
                loadFlags = loadFlags.subtracting([.forceDMG, .useGBA])
                
            case .GBA:
                loadFlags = loadFlags.subtracting(.forceDMG).union(.useGBA)
            }
            
            for key in keyToConsole.keys {
                didChangeValue(forKey: key)
            }
            
            emulationStateAccessQueue.sync {
                emulator.reset(with: loadFlags)
                audioEngine?.restartAudio()
            }
            
            fileURL?.setExtendedAttribute(name: consoleAttributeKey, value: console)
        }
    }
    
    override func value(forKey key: String) -> Any? {
        if let theConsole = keyToConsole[key] {
            return console == theConsole
            
        } else {
            return super.value(forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if let theConsole = keyToConsole[key] {
            console = theConsole
            
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    override var displayName: String! {
        get {
            // If possible, use the title in the ROM header
            return emulator.isLoaded ? emulator.romTitle : super.displayName
        }
        set {
            super.displayName = newValue
        }
    }
    
    func windowDidResignMain(_: Notification) {
        if UserDefaults.standard.bool(forKey: "Autosave") {
            saveSaveData()
        }
    }
    
    func windowDidResignKey(_: Notification) {
        shouldReschedule = true
    }
    
    func windowDidBecomeKey(_: Notification) {
        shouldReschedule = true
        
        if #available(macOS 10.12.2, *) {
            gbWindow?.touchBarController?.setUpDisplay()
        }
    }
    
    @IBAction func goToSaveState(_: NSMenuItem) {
        let controller = SaveState()
        controller.romURL = fileURL
        gbWindow?.beginSheet(controller.window!) { [weak self] response in
            if response == NSModalResponseOK, let state = controller.stateView?.selectedState {
                self?.saveState(id: state)
            }
        }
    }
    
    @IBAction func goToLoadState(_: NSMenuItem) {
        let controller = LoadState()
        controller.romURL = fileURL
        gbWindow?.beginSheet(controller.window!) { [weak self] response in
            if response == NSModalResponseOK, let state = controller.stateView?.selectedState {
                self?.loadState(id: state)
            }
        }
    }
    
    func saveState(id: Int) {
        emulationStateAccessQueue.async {
            self.emulator.currentState = id
            let notification = NSUserNotification()
            let notificationTime: TimeInterval
            
            do {
                try self.emulator.saveState(withVideoBuffer: &self.videoBuffer, pitch: 160)
                
                notification.title = NSLocalizedString("State Saved", comment: "Notification Title")
                notification.informativeText = String(format: NSLocalizedString("State %d has been saved.", comment: "Notification Body"), id + 1)
                notificationTime = 1.5
                
            } catch {
                notification.title = NSLocalizedString("Failed to Save State", comment: "Notification Title")
                notification.informativeText = NSLocalizedString("Please check that the states directory is writable.", comment: "Notification Body")
                notificationTime = 2.5
            }
            
            self.deliverTimedNotification(notification, time: notificationTime)
        }
    }
    
    func loadState(id: Int) {
        if let notificationTimer = notificationTimer, notificationTimer.isValid {
            notificationTimer.fire()
        }
        
        emulationStateAccessQueue.async {
            self.emulator.currentState = id
            let notification = NSUserNotification()
            let notificationTime: TimeInterval
            
            do {
                try self.emulator.loadState()
                notification.title = NSLocalizedString("State Loaded", comment: "Notification Title")
                notification.informativeText = String(format: NSLocalizedString("State %d has been loaded.", comment: "Notification Body"), id + 1)
                notificationTime = 1.5
                
            } catch {
                notification.title = NSLocalizedString("Failed to Load State", comment: "Notification Title")
                notification.informativeText = String(format: NSLocalizedString("Save a state beforehand using ⌥%d.", comment: "Notification Body"), (id + 1) % 10)
                notificationTime = 2.5
            }
            
            self.deliverTimedNotification(notification, time: notificationTime)
        }
    }
    
    private func deliverTimedNotification(_ notification: NSUserNotification, time: TimeInterval) {
        if UserDefaults.standard.bool(forKey: "StateNotifications") {
            DispatchQueue.main.async {
                self.notificationTimer = Timer.scheduled(withTimeInterval: time, repeats: false) { [weak self] _ in
                    self?.notificationTimer = nil
                    NSUserNotificationCenter.default.removeDeliveredNotification(notification)
                }
                self.notificationTimer?.tolerance = TimeInterval.infinity
            }
            
            notification.soundName = nil
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    deinit {
        audioEngine?.stopAudio()
        timer.cancel()
        
        if let saveStateObserver = saveStateObserver, let loadStateObserver = loadStateObserver {
            NotificationCenter.default.removeObserver(saveStateObserver)
            NotificationCenter.default.removeObserver(loadStateObserver)
        }
    }

}
