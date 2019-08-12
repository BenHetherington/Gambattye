//
//  Emulator.swift
//  Gambattye
//
//  Created by Ben Hetherington on 19/09/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

private let soundEnabledAttributeKey = "com.ben10do.Gambattye.SoundEnabled"
private let consoleAttributeKey = "com.ben10do.Gambattye.Console"

private let expectedSamples = 35112
private let frameRate = 262144.0 / 4389.0

class Emulator: NSObject {

    private(set) var romData = Data()
    private(set) var romUrl: URL?
    private let emulator = GB()
    private var timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue(label: "com.ben10do.Gambattye.EmulationTimer"))
    private let audioEngine: AudioEngine?
    private var internalSoundEnabled = true
    private let emulationStateAccessQueue = DispatchQueue(label: "com.ben10do.Gambattye.EmulationStateAccess")
    private var notificationTimer: Timer?

    var renderer: ((CGDataProvider) -> Void)?
    private var videoBuffer = [UInt32](repeating: 0xF8F8F8, count: 160 * 144)
    private var dataProvider: CGDataProvider?

    private var audioBuffer = [UInt32](repeating: 0, count: expectedSamples + 2064)

    private var shouldReschedule = false
    private var frameDivisor = 4

    private var observers = [NSObjectProtocol]()

    var runWithLowLatency = true {
        didSet {
            shouldReschedule = true
        }
    }

    private var loadFlags: LoadFlags = []
    private var keyToConsole = ["consoleIsGB": Console.GB, "consoleIsGBC": .GBC, "consoleIsGBA": .GBA]

    private var gbBootRomUrl: URL?
    private var gbcBootRomUrl: URL?

    override init() {
        do {
            try audioEngine = AudioEngine()
        } catch {
            Swift.print(error.localizedDescription)
            audioEngine = nil
            internalSoundEnabled = false
        }
        super.init()

        let setupBootRoms = { (key: String, url: ReferenceWritableKeyPath<Emulator, URL?>, gbc: Bool) -> NSObjectProtocol in
            self[keyPath: url] = UserDefaults.standard.url(forKey: key)
            return NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] _ in
                self?.emulationStateAccessQueue.async {
                    let newBootRomUrl = UserDefaults.standard.url(forKey: key)
                    if self?[keyPath: url] != newBootRomUrl {
                        self?[keyPath: url] = newBootRomUrl
                        if gbc {
                            self?.emulator.loadGBCBootROM(newBootRomUrl)
                        } else {
                            self?.emulator.loadDMGBootROM(newBootRomUrl)
                        }
                    }
                }
            }
        }

        observers += setupBootRoms("OriginalGBBootROM", \Emulator.gbBootRomUrl, false)
        observers += setupBootRoms("GBCBootROM", \Emulator.gbcBootRomUrl, true)

        emulator.loadDMGBootROM(gbBootRomUrl)
        emulator.loadGBCBootROM(gbcBootRomUrl)
    }

    func load(from url: URL) throws {
        romUrl = url

        try romData = Data(contentsOf: url) // Just in case someone tries to save the ROM
        console = url.getExtendedAttribute(name: consoleAttributeKey) ?? .GBC

        try emulationStateAccessQueue.sync {
            try emulator.load(from: url, flags: loadFlags)
        }
    }

    func beginEmulation(inputGetter: InputGetter) {
        emulator.setInputGetter(inputGetter)
        soundEnabled = romUrl?.getExtendedAttribute(name: soundEnabledAttributeKey) ?? true
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

            renderer?(dataProvider!)
        }
    }

    func reset() {
        emulationStateAccessQueue.sync {
            emulator.reset()
        }
    }

    private func rescheduleTimer(forStart: Bool) {
        frameDivisor = runWithLowLatency ? 4 : 1
        let leeway = DispatchTimeInterval.milliseconds(runWithLowLatency ? 1 : 5)
        let interval = 1 / (frameRate * Double(frameDivisor))
        let startTime = DispatchTime.now().uptimeNanoseconds + (forStart ? 100000000 : UInt64(interval * 1e9))
        timer.schedule(deadline: DispatchTime(uptimeNanoseconds: startTime), repeating: interval, leeway: leeway)
    }

    func saveSaveData() {
        emulationStateAccessQueue.sync {
            emulator.saveSaveData()
        }
    }

    @objc dynamic var soundEnabled: Bool {
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
                    romUrl?.setExtendedAttribute(name: soundEnabledAttributeKey, value: newValue)

                } catch {
                    let errorAlert = NSAlert()
                    errorAlert.messageText = NSLocalizedString("Failed to initialise audio.", comment: "Error title")
                    errorAlert.informativeText = error.localizedDescription
                    errorAlert.runModal()

                    internalSoundEnabled = false
                }
            }
        }
    }

    @objc dynamic var canEnableSound: Bool {
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

            romUrl?.setExtendedAttribute(name: consoleAttributeKey, value: console)

            NotificationCenter.default.post(name: .ConsoleChanged, object: self)
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
                self.notificationTimer?.tolerance = .infinity
            }

            notification.soundName = nil
            NSUserNotificationCenter.default.deliver(notification)
        }
    }

    var romTitle: String? {
        return emulator.isLoaded ? emulator.romTitle : nil
    }

    deinit {
        audioEngine?.stopAudio()
        timer.cancel()

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

}

extension NSNotification.Name {
    static let ConsoleChanged = NSNotification.Name("GBConsoleChanged")
}
