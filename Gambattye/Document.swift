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
    
    private var videoBuffer = [UInt32](repeating: 0xF8F8F8, count: 160 * 144)
    private var dataProvider: CGDataProvider?
    
    private var audioBuffer = [UInt32](repeating: 0, count: expectedSamples + 2064)
    
    private var shouldReschedule = false
    private var frameDivisor = 4
    
    private var loadFlags: LoadFlags = []
    private var keyToConsole = ["consoleIsGB": Console.GB, "consoleIsGBC": .GBC, "consoleIsGBA": .GBA]
    
    @IBOutlet var gbWindow: NSWindow? {
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
        frameDivisor = (gbWindow?.isMainWindow ?? false) ? 4 : 1
        let leeway = DispatchTimeInterval.milliseconds((gbWindow?.isMainWindow ?? false) ? 1 : 5)
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
    
    func windowDidResignMain(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: "Autosave") {
            saveSaveData()
        }
        shouldReschedule = true
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        shouldReschedule = true
    }
    
    deinit {
        audioEngine?.stopAudio()
        timer.cancel()
    }

}
