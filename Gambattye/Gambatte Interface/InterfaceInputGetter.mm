//
//  InterfaceInputGetter.mm
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

#import "InterfaceInputGetter.h"

InputGetterBridge::InputGetterBridge(id<InputGetterProtocol>input) {
    this->input = input;
}

unsigned InputGetterBridge::operator ()() {
    return [input getInput];
}
