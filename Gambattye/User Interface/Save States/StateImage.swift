//
//  StateImage.swift
//  Gambattye
//
//  Created by Ben10do on 28/06/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa

struct StateImage {
    
    let stateVersion: Int
    let imageData: Data
    
    private var width: Int {
        return stateVersion >= 2 ? 160 : 40
    }
    
    private var height: Int {
        return stateVersion >= 2 ? 144 : 36
    }
    
    init?(fromState stateURL: URL) {
        do {
            let handle = try FileHandle(forReadingFrom: stateURL)
            stateVersion = StateImage.dataToBigInt(handle.readData(ofLength: 2))
            
            let size = StateImage.dataToBigInt(handle.readData(ofLength: 3))
            imageData = handle.readData(ofLength: size)
            
        } catch {
            return nil
        }
    }
    
    func toNSImage() -> NSImage? {
        if let cgImage = toCGImage() {
            return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
        } else {
            return nil
        }
    }
    
    func toCGImage() -> CGImage? {
        let dataProvider = CGDataProvider(data: imageData as CFData)!
        let bytesPerRow = imageData.count / height
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue), provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
    
    private static func dataToBigInt(_ data: Data) -> Int {
        var value = 0
        for i in 0..<data.count {
            value |= Int(data[i]) << (8 * (data.count - 1 - i))
        }
        return value
    }
    
}
