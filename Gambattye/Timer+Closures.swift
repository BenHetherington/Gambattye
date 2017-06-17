//
//  Timer+Closures.swift
//  Gambattye
//
//  Created by Ben10do on 17/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Foundation

extension Timer {
    
    class func scheduled(withTimeInterval time: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        if #available(macOS 10.12, *) {
            return scheduledTimer(withTimeInterval: time, repeats: repeats, block: block)
        } else {
            return scheduledTimer(timeInterval: time, target: self, selector: #selector(Timer.callback(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc private func callback(_ timer: Timer) {
        if let block = timer.userInfo as? (Timer) -> Void {
            block(timer)
        }
    }
    
}
