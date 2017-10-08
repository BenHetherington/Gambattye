//
//  UrlStorage.swift
//  Gambattye
//
//  Created by Ben10do on 26/09/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

class UrlStorage: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSURL.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value as? NSString {
            return NSURL(fileURLWithPath: value.expandingTildeInPath)
        } else {
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        if let value = value as? NSURL {
            return value.path
        } else {
            return nil
        }
    }

}
