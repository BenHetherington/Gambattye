//
//  InterfaceInputGetter.mm
//  Gambattye
//
//  Created by Ben Hetherington on 29/01/2017.
//  Copyright © 2017 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

#import "InterfaceInputGetter.h"

InputGetterBridge::InputGetterBridge(id<InputGetterProtocol>input) {
    this->input = input;
}

unsigned InputGetterBridge::operator ()() {
    return [input getInput];
}
