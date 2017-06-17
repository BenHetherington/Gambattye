//
//  VibrantDarkWindow.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

@IBDesignable class VibrantDarkWindow: NSWindow {
    
    private var trackingArea: NSTrackingArea?
    private var timer: Timer?
    private(set) var isFullScreen = false
    
    private var enterFullScreenObserver: NSObjectProtocol?
    private var exitFullScreenObserver: NSObjectProtocol?
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        trackingArea = NSTrackingArea(rect: NSRect(), options: [.inVisibleRect, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        
        enterFullScreenObserver = NotificationCenter.default.addObserver(forName: .NSWindowDidEnterFullScreen, object: self, queue: nil) {[weak self] (_) in
            self?.isFullScreen = true
            self?.hideMouseAfterDelay()
            
            if let trackingArea = self?.trackingArea {
                self?.contentView?.addTrackingArea(trackingArea)
            }
        }
        
        exitFullScreenObserver = NotificationCenter.default.addObserver(forName: .NSWindowDidExitFullScreen, object: self, queue: nil) {[weak self] (_) in
            self?.isFullScreen = false
            self?.disableHiddenMouse()
            
            if let trackingArea = self?.trackingArea {
                self?.contentView?.removeTrackingArea(trackingArea)
            }
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        appearance = appearance ?? NSAppearance(named: NSAppearanceNameVibrantDark)
        backgroundColor = NSColor.black
    }
    
    func hideMouseAfterDelay() {
        timer?.invalidate()
        timer = Timer.scheduled(withTimeInterval: 3, repeats: false) { _ in
            NSCursor.setHiddenUntilMouseMoves(true)
        }
    }
    
    func disableHiddenMouse() {
        timer?.invalidate()
        NSCursor.setHiddenUntilMouseMoves(false)
    }
    
    override func mouseMoved(with event: NSEvent) {
        hideMouseAfterDelay()
    }
    
    deinit {
        if let enterFullScreenObserver = enterFullScreenObserver, let exitFullScreenObserver = exitFullScreenObserver {
            NotificationCenter.default.removeObserver(enterFullScreenObserver)
            NotificationCenter.default.removeObserver(exitFullScreenObserver)
        }
    }
    
}

@available(macOS 10.12.2, *)
extension VibrantDarkWindow {
    override func makeTouchBar() -> NSTouchBar? {
        var objects = NSArray()
        NSNib(nibNamed: "Touch Bar", bundle: nil)?.instantiate(withOwner: self, topLevelObjects: &objects)
        
        for object in objects {
            if let object = object as? NSTouchBar {
                return object
            }
        }
        
        return nil
    }

}
