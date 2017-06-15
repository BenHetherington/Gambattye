//
//  TPCircularBuffer.swift
//  Gambattye
//
//  Created by Ben10do on 15/06/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Foundation
import TPCircularBuffer

extension TPCircularBuffer {
    
    init(length: Int32) {
        self.init()
        _TPCircularBufferInit(&self, length, MemoryLayout<TPCircularBuffer>.size)
    }
    
    mutating func clear() {
        TPCircularBufferClear(&self)
    }
    
    mutating func tail() -> (UnsafeMutableRawPointer?, Int32) {
        var availableBytes: Int32 = 0
        let tail = TPCircularBufferTail(&self, &availableBytes)
        return (tail, availableBytes)
    }
    
    mutating func consume(bytes: Int32) {
        TPCircularBufferConsume(&self, bytes)
    }
    
    @discardableResult mutating func produceBytes(from source: [UInt32], count: Int32) -> Bool {
        return produceBytes(from: source, length: Int32(MemoryLayout<UInt32>.size) * count)
    }
    
    @discardableResult mutating func produceBytes(from source: UnsafeRawPointer, length: Int32) -> Bool {
        return TPCircularBufferProduceBytes(&self, source, length)
    }
    
    mutating func cleanup() {
        TPCircularBufferCleanup(&self)
    }
    
}
