//
//  GBWindow.swift
//  Gambattye
//
//  Created by Ben10do on 29/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

@IBDesignable class GBWindow: VibrantDarkWindow {
    
    private var trackingArea: NSTrackingArea?
    private var timer: Timer?
    private(set) var isFullScreen = false

    private var observers = [NSObjectProtocol]()
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        trackingArea = NSTrackingArea(rect: NSRect(), options: [.inVisibleRect, .mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        
        observers += NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: self, queue: nil) { [weak self] _ in
            self?.isFullScreen = true
            self?.hideMouseAfterDelay()
            
            if let trackingArea = self?.trackingArea {
                self?.contentView?.addTrackingArea(trackingArea)
            }
        }
        
        observers += NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: self, queue: nil) { [weak self] _ in
            self?.isFullScreen = false
            self?.disableHiddenMouse()
            
            if let trackingArea = self?.trackingArea {
                self?.contentView?.removeTrackingArea(trackingArea)
            }
        }
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
    
    override func mouseEntered(with event: NSEvent) {
        hideMouseAfterDelay()
    }
    
    override func mouseMoved(with event: NSEvent) {
        hideMouseAfterDelay()
    }
    
    override func mouseExited(with event: NSEvent) {
        disableHiddenMouse()
    }
    
    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
}

private var touchBarControllerKey = "TouchBarControllerKey"

@available(macOS 10.12.2, *)
extension GBWindow {
    
    override func makeTouchBar() -> NSTouchBar? {
        if touchBarController == nil {
            touchBarController = TouchBarController()
        }
        touchBarController?.romURL = representedURL
        return touchBarController?.touchBar
    }
    
    var touchBarController: TouchBarController? {
        get {
            return objc_getAssociatedObject(self, &touchBarControllerKey) as? TouchBarController
        }
        set {
            objc_setAssociatedObject(self, &touchBarControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}
