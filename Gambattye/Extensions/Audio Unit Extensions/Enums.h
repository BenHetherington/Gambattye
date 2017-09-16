//
//  Enums.h
//  Gambattye
//
//  Created by Ben10do on 08/09/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

#import <AudioToolbox/AudioToolbox.h>

/// Audio units are classified into different types, where those types perform
/// different roles and functions.
typedef NS_ENUM(OSType, AudioUnitType) {
    /// An output unit can be used as the head of an AUGraph. Apple provides a number
    /// of output units that interface directly with an audio device.
    Output = kAudioUnitType_Output
};

/// Apple input/output audio unit sub types (for macOS).
typedef NS_ENUM(OSType, AudioUnitSubType) {
    /// A specialisation of HALOutput that is used to track the user's selection of the
    /// default device as set in the Sound Preferences.
    DefaultOutput = kAudioUnitSubType_DefaultOutput
};

/// Audio unit manufacturers (used by Gambattye)
typedef NS_ENUM(OSType, AudioUnitManufacturer) {
    /// The unique ID used to identify audio units provided by Apple.
    Apple = kAudioUnitManufacturer_Apple
};
