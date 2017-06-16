//
//  InterfaceInputGetter.mm
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

#import "InterfaceInputGetter.h"

InputGetterBridge::InputGetterBridge(id<InputGetterProtocol>input) {
    this->input = input;
}

unsigned InputGetterBridge::operator ()() {
    return [input getInput];
}
