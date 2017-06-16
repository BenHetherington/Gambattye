//
//  InterfaceInputGetter.h
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

#import <Foundation/Foundation.h>

// Redefined explicitly, to ensure usability from Swift without having to reference any C++ types
typedef NS_OPTIONS(unsigned, Buttons) {
    ButtonsA = 1,
    ButtonsB = 2,
    ButtonsSelect = 4,
    ButtonsStart = 8,
    ButtonsRight = 16,
    ButtonsLeft = 32,
    ButtonsUp = 64,
    ButtonsDown = 128
};

@protocol InputGetterProtocol <NSObject>

- (Buttons)getInput;

@end

#ifdef __cplusplus

#import "libgambatte/include/inputgetter.h"

class InputGetterBridge : public gambatte::InputGetter {
private:
    id<InputGetterProtocol> input;
    
public:
    InputGetterBridge(id<InputGetterProtocol>input);
    unsigned operator ()();
};
#endif
