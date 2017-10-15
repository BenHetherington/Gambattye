//
//  AboutPanelController.swift
//  Gambattye
//
//  Created by Ben10do on 14/10/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class AboutPanelController: NSWindowController {

    @IBOutlet private weak var iconView: NSImageView!
    @IBOutlet private weak var appNameView: NSTextField!
    @IBOutlet private weak var versionView: NSTextField!
    @IBOutlet private weak var creditsView: NSTextView!
    @IBOutlet private weak var copyrightView: NSTextField!

    var aboutPanel: NSPanel? {
        return window as? NSPanel
    }

    var appearance: NSAppearance?

    private var icon: NSImage? {
        get {
            return iconView.image
        }
        set {
            iconView.image = newValue
        }
    }

    private var appName: String {
        get {
            return appNameView.stringValue
        }
        set {
            appNameView.stringValue = newValue
        }
    }

    private var shortVersion: String = "" {
        didSet {
            updateVersionText()
        }
    }

    private var version: String = "" {
        didSet {
            updateVersionText()
        }
    }

    private var credits: NSAttributedString {
        get {
            return creditsView.attributedString()
        }
        set {
            creditsView.textStorage?.setAttributedString(newValue)
        }
    }

    private var copyright: String {
        get {
            return copyrightView.stringValue
        }
        set {
            copyrightView.stringValue = newValue
        }
    }

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("AboutPanel")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.appearance = NSAppearance(named: .vibrantDark)
    }

    func orderFrontAboutPanel(_ sender: Any?) {
        orderFrontAboutPanel()
    }

    func orderFrontAboutPanel(options: [NSApplication.AboutPanelOptionKey : Any]) {
        // TODO: Use the enum values if the minimum macOS version is increased to macOS 10.13
        orderFrontAboutPanel(icon: options[NSApplication.AboutPanelOptionKey(rawValue: "ApplicationIcon")] as? NSImage,
                             appName: options[NSApplication.AboutPanelOptionKey(rawValue: "ApplicationName")] as? String,
                             shortVersion: options[NSApplication.AboutPanelOptionKey(rawValue: "ApplicationVersion")] as? String,
                             version: options[NSApplication.AboutPanelOptionKey(rawValue: "Version")] as? String,
                             credits: options[NSApplication.AboutPanelOptionKey(rawValue: "Credits")] as? NSAttributedString,
                             copyright: options[NSApplication.AboutPanelOptionKey(rawValue: "Copyright")] as? String)
    }

    func orderFrontAboutPanel(icon: NSImage? = nil, appName: String? = nil, shortVersion: String? = nil, version: String? = nil, credits: NSAttributedString? = nil, copyright: String? = nil) {
        // Setting up the window also ensures that it's loaded!
        guard let window = window else {
            return
        }

        window.appearance = appearance

        // We only care about string values, so let's get rid of the values we don't need to avoid casting
        let inputAppInfo = Bundle.main.localizedInfoDictionary ?? Bundle.main.infoDictionary ?? [:]
        let filteredAppInfo = inputAppInfo.filter { (_, value) in
            return value is String
        }
        let appInfo = filteredAppInfo as? [String: String] ?? [:]

        self.icon = icon ?? NSImage(named: .applicationIcon) ?? NSWorkspace.shared.icon(forFileType: "app")
        self.appName = appName ?? appInfo["CFBundleName"] ?? ProcessInfo.processInfo.processName
        self.shortVersion = shortVersion ?? appInfo["CFBundleShortVersionString"] ?? ""
        self.version = version ?? appInfo["CFBundleVersion"] ?? ""
        self.credits = credits ?? storedCreditsText
        self.copyright = copyright ?? appInfo["NSHumanReadableCopyright"] ?? ""

        window.makeKeyAndOrderFront(self)

        prepareCreditsAttributes()
    }

    private func updateVersionText() {
        versionView.stringValue = shortVersion.isEmpty ? "" : "Version " + shortVersion
        versionView.stringValue += shortVersion.isEmpty || version.isEmpty ? "" : " "
        versionView.stringValue += version.isEmpty ? "" : "(" + version + ")"
    }

    private var storedCreditsText: NSAttributedString {
        for fileExtension in ["html", "rtf", "rtfd"] {
            if let creditsUrl = Bundle.main.url(forResource: "Credits", withExtension: fileExtension) {
                do {
                    return try NSAttributedString(url: creditsUrl, documentAttributes: nil)
                } catch {
                    // Then we'll try the next file extension, or just use an empty string
                }
            }
        }

        return NSAttributedString()
    }

    private func prepareCreditsAttributes() {
        creditsView.textColor = NSColor.labelColor
        creditsView.linkTextAttributes?[NSAttributedStringKey.foregroundColor] = NSColor.systemBlue

        // Let's also flash the scrollers if we need to
        let creditsScrollView = creditsView?.superview?.superview as? NSScrollView
        creditsScrollView?.flashScrollers()
    }

}
