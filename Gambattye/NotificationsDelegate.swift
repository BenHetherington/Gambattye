//
//  NotificationsDelegate.swift
//  Gambattye
//
//  Created by Ben Hetherington on 28/06/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class NotificationsDelegate: NSObject, NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent _: NSUserNotification) -> Bool {
        return true
    }
    
}
