//
//  AudioComponentDescription.swift
//  Gambattye
//
//  Created by Ben Hetherington on 08/09/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import AudioToolbox

extension AudioComponentDescription {

    init(type: AudioUnitType, subType: AudioUnitSubType, manufacturer: AudioUnitManufacturer) {
        self.init(componentType: type.rawValue, componentSubType: subType.rawValue, componentManufacturer: manufacturer.rawValue, componentFlags: 0, componentFlagsMask: 0)
    }

}
