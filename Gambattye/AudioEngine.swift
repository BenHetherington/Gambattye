//
//  AudioEngine.swift
//  Gambattye
//
//  Created by Ben10do on 30/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import CoreAudio
import AudioToolbox
import TPCircularBuffer

private let initError = NSError(domain: "GambattyeSoundErrorDomain", code: 0, userInfo:
    [NSLocalizedDescriptionKey: NSLocalizedString("Falied to enable sound.", comment: ""),
     NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please ensure that your computer's audio is working.", comment: "")])
private let bufferLength = 1024 * 1024

class AudioEngine {
    private var audioComponent: AudioComponent
    private var audioComponentInstance: AudioComponentInstance
    private var renderVars = RenderVars()
    
    private class RenderVars {
        var lastSample: UInt32 = 0
        var circularBuffer = TPCircularBuffer(length: 1024 * 1024)
    }
    
    init() throws {
        var desc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_DefaultOutput, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        
        if let audioComponent = AudioComponentFindNext(nil, &desc) {
            self.audioComponent = audioComponent
        } else {
            throw initError
        }
        
        var audioComponentInstance: AudioComponentInstance?
        if AudioComponentInstanceNew(audioComponent, &audioComponentInstance) == noErr, let audioComponentInstance = audioComponentInstance {
            self.audioComponentInstance = audioComponentInstance
        } else {
            throw initError
        }
    }
    
    func startAudio() throws {
        let render: AURenderCallback = {(dataQueuePointer, _, _, _, inNumberFrames, ioData) -> OSStatus in
            let renderVars = dataQueuePointer.load(as: RenderVars.self)
            if let buffer = UnsafeMutablePointer<UInt32>(OpaquePointer(ioData?[0].mBuffers.mData)) {
                let (data, bytes) = renderVars.circularBuffer.tail()
                
                let framesToCopy = min(Int(bytes) / MemoryLayout<UInt32>.size, Int(inNumberFrames))
                let bytesToCopy = framesToCopy * MemoryLayout<UInt32>.size
                memcpy(buffer, data, bytesToCopy)
                renderVars.circularBuffer.consume(bytes: Int32(bytesToCopy))
                
                if framesToCopy > 0 {
                    renderVars.lastSample = buffer[framesToCopy - 1]
                }
                
                for i in framesToCopy..<Int(inNumberFrames) {
                    buffer[i] = renderVars.lastSample
                }
            }
            
            return noErr
        }
        
        let callback = AURenderCallbackStruct(inputProc: render, inputProcRefCon: &renderVars)
        try startAudio(rate: 35112 * (262144.0 / 4389.0), callback: callback)
    }
    
    func startAudio(rate: Float64, callback inputCallback: AURenderCallbackStruct) throws {
        var callback = inputCallback
        var error = noErr
        
        error = AudioUnitInitialize(audioComponentInstance)
        guard error == noErr else {
            throw initError
        }
        
        var streamFormat = AudioStreamBasicDescription(mSampleRate: rate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
        
        error = AudioUnitSetProperty(audioComponentInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, UInt32(MemoryLayout.size(ofValue: streamFormat)))
        guard error == noErr else {
            throw initError
        }
        
        error = AudioUnitSetProperty(audioComponentInstance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callback, UInt32(MemoryLayout.size(ofValue: callback)))
        guard error == noErr else {
            throw initError
        }
        
        restartAudio()
        
        error = AudioOutputUnitStart(audioComponentInstance)
        guard error == noErr else {
            throw initError
        }
    }
    
    func stopAudio() {
        AudioOutputUnitStop(audioComponentInstance)
    }
    
    func restartAudio() {
        renderVars.circularBuffer.clear()
    }
    
    func pushData(newData: [UInt32], count: Int) {
        renderVars.circularBuffer.produceBytes(from: newData, count: Int32(count))
    }
    
    deinit {
        AudioOutputUnitStop(audioComponentInstance)
        AudioComponentInstanceDispose(audioComponentInstance)
        renderVars.circularBuffer.cleanup()
    }
    
}
