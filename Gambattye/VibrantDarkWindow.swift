//
//  VibrantDarkWindow.swift
//  Gambattye
//
//  Created by Ben10do on 28/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa

@IBDesignable class VibrantDarkWindow: NSWindow {
    
    var timer: Timer?
    var isFullScreen = false
    
//    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
//        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
//        let trackingArea = NSTrackingArea(rect: NSRect(), options: [.inVisibleRect, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
//        contentView?.addTrackingArea(trackingArea)
//        
//        NotificationCenter.default.addObserver(forName: .NSWindowDidEnterFullScreen, object: self, queue: nil) {[weak self] (_) in
//            Swift.print("To full screen")
//            self?.isFullScreen = true
//            self?.acceptsMouseMovedEvents = true
//            self?.hideMouseAfterDelay()
//        }
//        NotificationCenter.default.addObserver(forName: .NSWindowDidExitFullScreen, object: self, queue: nil) {[weak self] (_) in
//            Swift.print("Outta full screen")
//            self?.isFullScreen = false
//            self?.acceptsMouseMovedEvents = false
//            self?.disableHiddenMouse()
//        }
//    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        appearance = appearance ?? NSAppearance(named: NSAppearanceNameVibrantDark)
        backgroundColor = NSColor.black
    }
    
//    func hideMouseAfterDelay() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
//            NSCursor.setHiddenUntilMouseMoves(true)
//        }
//    }
//    
//    func disableHiddenMouse() {
//        timer?.invalidate()
//        NSCursor.setHiddenUntilMouseMoves(false)
//    }
//    
//    override func mouseMoved(with event: NSEvent) {
//        Swift.print("moved")
//        hideMouseAfterDelay()
//    }
    
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
