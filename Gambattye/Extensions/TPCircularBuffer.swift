//
//  TPCircularBuffer.swift
//  Gambattye
//
//  Created by Ben10do on 15/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Foundation
import TPCircularBuffer

extension TPCircularBuffer {
    
    init(length: UInt32) {
        self.init()
        _TPCircularBufferInit(&self, length, MemoryLayout<TPCircularBuffer>.size)
    }
    
    mutating func clear() {
        TPCircularBufferClear(&self)
    }
    
    mutating func tail() -> (UnsafeMutableRawPointer?, UInt32) {
        var availableBytes: UInt32 = 0
        let tail = TPCircularBufferTail(&self, &availableBytes)
        return (tail, availableBytes)
    }
    
    mutating func consume(bytes: UInt32) {
        TPCircularBufferConsume(&self, bytes)
    }
    
    @discardableResult mutating func produceBytes(from source: [UInt32], count: UInt32) -> Bool {
        return produceBytes(from: source, length: UInt32(MemoryLayout<UInt32>.size) * count)
    }
    
    @discardableResult mutating func produceBytes(from source: UnsafeRawPointer, length: UInt32) -> Bool {
        return TPCircularBufferProduceBytes(&self, source, length)
    }
    
    mutating func cleanup() {
        TPCircularBufferCleanup(&self)
    }
    
}
