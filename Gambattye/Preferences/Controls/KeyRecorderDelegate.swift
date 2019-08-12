//
//  KeyRecorderDelegate.swift
//  Gambattye
//
//  Created by Ben Hetherington on 09/04/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Cocoa
import ShortcutRecorder

class KeyRecorderDelegate: NSObject, SRRecorderControlDelegate {
    
    func shortcutRecorderDidEndRecording(_ recorder: SRRecorderControl!) {
        if let recorder = recorder as? KeyRecorderControl {
            let defaultsKey = recorder.name + "ButtonKey"
            UserDefaults.standard.set(recorder.objectValue, forKey: defaultsKey)
        }
    }

}
