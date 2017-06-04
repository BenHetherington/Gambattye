//
//  AudioEngine.swift
//  Gambattye
//
//  Created by Ben10do on 30/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

import CoreAudio
import AudioToolbox

private let initError = NSError(domain: "GambattyeSoundErrorDomain", code: 0, userInfo:
    [NSLocalizedDescriptionKey: NSLocalizedString("Falied to enable sound.", comment: ""),
     NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please ensure that your computer's audio is working.", comment: "")])

class AudioEngine {
    private var audioComponent: AudioComponent
    private var audioComponentInstance: AudioComponentInstance
    private var renderVars = RenderVars()
    
    private class RenderVars {
        var lastSample: UInt32 = 0
        var dataBuffer = [[UInt32]]()
        var positionInDataBuffer = 0
        var dataBufferToRead = 0
        var dataBufferToWrite = 0
        var dataBufferDifference = 0
        let dataAccessQueue = DispatchQueue(label: "com.ben10do.Gambattye.AudioEngine.DataAccess")
        let sampleSkip = AudioEngine.sampleSkip
    }
    
    private class var sampleSkip: Int {
        return UserDefaults.standard.integer(forKey: "AudioSampleSkip")
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
        let render: AURenderCallback = {(dataQueuePointer, _, inTimeStamp, _, inNumberFrames, ioData) -> OSStatus in
            let renderVars = dataQueuePointer.load(as: RenderVars.self)
            if let buffer = UnsafeMutablePointer<UInt32>(OpaquePointer(ioData?[0].mBuffers.mData)) {
                var i = 0
                let count = Int(inNumberFrames)
                renderVars.dataAccessQueue.sync {
                    while i < count && renderVars.dataBufferDifference > 0 {
                        buffer[i] = renderVars.dataBuffer[renderVars.dataBufferToRead][renderVars.positionInDataBuffer]
                        renderVars.lastSample = buffer[i]
                        
                        i += 1
                        renderVars.positionInDataBuffer += renderVars.sampleSkip
                        
                        if renderVars.positionInDataBuffer >= renderVars.dataBuffer[renderVars.dataBufferToRead].count {
                            renderVars.positionInDataBuffer %= renderVars.dataBuffer[renderVars.dataBufferToRead].count
                            renderVars.dataBufferToRead += 1
                            renderVars.dataBufferToRead %= renderVars.dataBuffer.count
                            renderVars.dataBufferDifference -= 1
                        }
                    }
                }
                
                while i < count {
                    buffer[i] = renderVars.lastSample
                    i += 1
                }
            }
            
            return noErr
        }
        
        let callback = AURenderCallbackStruct(inputProc: render, inputProcRefCon: &renderVars)
        try startAudio(rate: (35112 * (262144.0 / 4389.0)) / Double(AudioEngine.sampleSkip), callback: callback)
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
        renderVars.dataAccessQueue.sync {
            self.renderVars.dataBuffer = [[UInt32]](repeatElement([], count: 8))
            self.renderVars.positionInDataBuffer = 0
            self.renderVars.dataBufferToRead = 0
            self.renderVars.dataBufferToWrite = 0
            self.renderVars.dataBufferDifference = 0
        }
    }
    
    func pushData(newData: [UInt32]) {
        renderVars.dataAccessQueue.async {
            self.renderVars.dataBuffer[self.renderVars.dataBufferToWrite] = newData
            self.renderVars.dataBufferToWrite += 1
            self.renderVars.dataBufferToWrite %= self.renderVars.dataBuffer.count
            self.renderVars.dataBufferDifference += 1
            self.renderVars.dataBufferDifference %= self.renderVars.dataBuffer.count
        }
    }
    
    deinit {
        AudioOutputUnitStop(audioComponentInstance)
        AudioComponentInstanceDispose(audioComponentInstance)
    }
    
}
