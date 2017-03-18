//
//  AudioEngine.swift
//  Gambattye
//
//  Created by Ben10do on 30/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import Cocoa
import CoreAudio
import AudioToolbox

class AudioEngine {
    fileprivate var audioComponent: AudioComponent
    fileprivate var audioComponentInstance: AudioComponentInstance
    fileprivate var renderVars = RenderVars()
    
    class RenderVars {
        fileprivate var dataQueue = [[UInt32]]()
        fileprivate var positionInData = 0
        fileprivate let dataAccessQueue = DispatchQueue(label: "com.ben10do.Gambattye.AudioEngine.DataAccess")
        
    }
    
    init() throws {
        var desc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_DefaultOutput, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        
        if let audioComponent = AudioComponentFindNext(nil, &desc) {
            self.audioComponent = audioComponent
        } else {
            throw NSError() // TODO: Throw a more specific error
        }
        
        var audioComponentInstance: AudioComponentInstance?
        if AudioComponentInstanceNew(audioComponent, &audioComponentInstance) == noErr, let audioComponentInstance = audioComponentInstance {
            self.audioComponentInstance = audioComponentInstance
        } else {
            throw NSError() // TODO: Throw a more specific error
        }
    }
    
    func startAudio() throws {
        let render: AURenderCallback = {(dataQueuePointer, _, inTimeStamp, _, inNumberFrames, ioData) -> OSStatus in
            let renderVars = dataQueuePointer.load(as: RenderVars.self)
            if let buffer = UnsafeMutablePointer<UInt32>(OpaquePointer(ioData?[0].mBuffers.mData)) {
                var i = 0
                let count = Int(inNumberFrames)
                renderVars.dataAccessQueue.sync {
                    while i < count && renderVars.dataQueue.count > 0 {
                        buffer[i] = renderVars.dataQueue[0][renderVars.positionInData]
                        
                        i += 1
                        renderVars.positionInData += 45
                        
                        if renderVars.positionInData >= renderVars.dataQueue[0].count {
                            renderVars.positionInData %= renderVars.dataQueue[0].count
                            renderVars.dataQueue.removeFirst()
                        }
                    }
                }
                
                while i < count {
                    buffer[i] = 0xE200E200
                    i += 1
                }
            }
            
            return noErr
        }
        
        let callback = AURenderCallbackStruct(inputProc: render, inputProcRefCon: &renderVars)
        try startAudio(rate: (35112 * (262144.0 / 4389.0)) / 45.0, callback: callback)
    }
    
    func startAudio(rate: Float64, callback inputCallback: AURenderCallbackStruct) throws {
        var callback = inputCallback
        var error = noErr
        
        error = AudioUnitInitialize(audioComponentInstance)
        guard error == noErr else {
            throw NSError() // TODO: Throw a more specific error
        }
        
        var streamFormat = AudioStreamBasicDescription(mSampleRate: rate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
        
        error = AudioUnitSetProperty(audioComponentInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, UInt32(MemoryLayout.size(ofValue: streamFormat)))
        guard error == noErr else {
            throw NSError() // TODO: Throw a more specific error
        }
        
        error = AudioUnitSetProperty(audioComponentInstance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callback, UInt32(MemoryLayout.size(ofValue: callback)))
        guard error == noErr else {
            throw NSError() // TODO: Throw a more specific error
        }
        
        renderVars.dataQueue.removeAll()
        
        error = AudioOutputUnitStart(audioComponentInstance)
        guard error == noErr else {
            throw NSError() // TODO: Throw a more specific error
        }
    }
    
    func stopAudio() {
        AudioOutputUnitStop(audioComponentInstance)
    }
    
    func restartAudio() {
        renderVars.dataAccessQueue.sync {
            self.renderVars.dataQueue.removeAll()
            self.renderVars.positionInData = 0
        }
    }
    
    func pushData(newData: [UInt32]) {
        renderVars.dataAccessQueue.async {
            if self.renderVars.dataQueue.count > 8 { // TODO: Find a better solution
                // This hack ensures that the audio and video remain in sync
                self.renderVars.dataQueue.removeAll()
                self.renderVars.positionInData = 0
            }
            self.renderVars.dataQueue.append(newData)
        }
    }
    
    deinit {
        AudioOutputUnitStop(audioComponentInstance)
        AudioComponentInstanceDispose(audioComponentInstance)
    }
    
}
