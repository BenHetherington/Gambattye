//
//  URL+ExtendedAttributes.swift
//  Gambattye
//
//  Created by Ben10do on 02/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

extension URL {
    
    func getExtendedAttribute<T>(name: String) -> T? {
        var value = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        let pointer = UnsafeMutableRawPointer(&value)
        
        if getxattr(path, name, pointer, MemoryLayout<T>.size, 0, 0) > 0 {
            return pointer.load(as: T.self)
        } else {
            return nil
        }
    }
    
    func getExtendedAttribute<T: RawRepresentable>(name: String) -> T? {
        if let rawValue: T.RawValue = getExtendedAttribute(name: name) {
            return T(rawValue: rawValue)
        } else {
            return nil
        }
    }
    
    func getExtendedAttribute(name: String, length userLength: Int = -1) -> String? {
        let length = userLength >= 0 ? userLength : getxattr(path, name, nil, 0, 0, 0)
        var value = [CChar](repeating: 0, count: length + 1)
        
        if getxattr(path, name, &value, length + 1, 0, 0) > 0 {
            value[length] = 0 // Try to avoid any buffer overruns
            return String(cString: &value)
        } else {
            return nil
        }
    }
    
    @discardableResult func setExtendedAttribute<T>(name: String, value: T) -> Bool {
        var value = value
        return setxattr(path, name, &value, MemoryLayout<T>.size, 0, 0) == 0
    }
    
    @discardableResult func setExtendedAttribute<T: RawRepresentable>(name: String, value: T) -> Bool {
        return setExtendedAttribute(name: name, value: value.rawValue)
    }
    
    @discardableResult func setExtendedAttribute(name: String, value: String) -> Bool {
        var value = value.utf8CString
        return setxattr(path, name, &value, value.count, 0, 0) == 0
    }

}
