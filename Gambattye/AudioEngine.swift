//
//  AudioEngine.swift
//  Gambattye
//
//  Created by Ben Hetherington on 30/01/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import CoreAudio
import AudioToolbox
import AVFoundation
import TPCircularBuffer

private let bufferLength = 1024 * 1024

class AudioEngine {
    private var audioUnit: AUAudioUnit
    private var renderVars = RenderVars()
    
    private class RenderVars {
        var lastSample: UInt32 = 0
        var circularBuffer = TPCircularBuffer(length: 1024 * 1024)
    }
    
    init() throws {
        let desc = AudioComponentDescription(type: .Output, subType: .DefaultOutput, manufacturer: .Apple)
        audioUnit = try AUAudioUnit(componentDescription: desc)
    }
    
    func startAudio() throws {
        let sampleRate = 35112 * (262144.0 / 4389.0)

        let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: sampleRate, channels: 2, interleaved: true)!
        try audioUnit.inputBusses[0].setFormat(format)

        audioUnit.outputProvider = { [weak self] _, _, frameCount, _, inputData in
            if let renderVars = self?.renderVars {
                if let buffer = UnsafeMutablePointer<UInt32>(OpaquePointer(inputData[0].mBuffers.mData)) {
                    let (data, bytes) = renderVars.circularBuffer.tail()

                    let framesToCopy = min(Int(bytes) / MemoryLayout<UInt32>.size, Int(frameCount))
                    let bytesToCopy = framesToCopy * MemoryLayout<UInt32>.size
                    memcpy(buffer, data, bytesToCopy)
                    renderVars.circularBuffer.consume(bytes: UInt32(bytesToCopy))

                    if framesToCopy > 0 {
                        renderVars.lastSample = buffer[framesToCopy - 1]
                    }

                    for i in framesToCopy ..< Int(frameCount) {
                        buffer[i] = renderVars.lastSample
                    }

                    return noErr
                }
            }
            
            return noErr
        }

        restartAudio()
        try audioUnit.allocateRenderResources()
        try audioUnit.startHardware()
    }
    
    func stopAudio() {
        audioUnit.stopHardware()
    }
    
    func restartAudio() {
        renderVars.circularBuffer.clear()
    }
    
    func pushData(newData: [UInt32], count: Int) {
        renderVars.circularBuffer.produceBytes(from: newData, count: UInt32(count))
    }
    
    deinit {
        stopAudio()
        renderVars.circularBuffer.cleanup()
    }
    
}
