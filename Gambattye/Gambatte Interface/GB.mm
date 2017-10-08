//
//  GB.mm
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

#import "GB.h"
#import "libgambatte/include/gambatte.h"
#import "libgambatte/include/pakinfo.h"

const NSErrorDomain GBErrorDomain = @"com.Ben10do.Gambattye.Interface";

@interface GB ()

@property (assign) gambatte::GB *GB;
@property (assign) gambatte::InputGetter *internalInputGetter;

@end

@implementation GB

- (instancetype)init {
    self = [super init];
    if (self) {
        _GB = new gambatte::GB();
    }
    return self;
}

- (void)dealloc {
    delete _GB;
    delete _internalInputGetter;
}

- (BOOL)loadFrom:(NSURL *)ROMURL flags:(LoadFlags)flags error:(NSError **)error {
    std::string path = [[ROMURL path] UTF8String];
    gambatte::LoadRes result = _GB->load(path, flags);
    
    if (result == gambatte::LOADRES_OK) {
        return true;
        
    } else {
        if (error) {
            *error = [NSError errorWithDomain:GBErrorDomain code:result userInfo:nil];
        }
        return false;
    }
}

- (ptrdiff_t)runWithVideoBuffer:(uint_least32_t *)videoBuffer pitch:(ptrdiff_t)pitch audioBuffer:(uint_least32_t *)audioBuffer samples:(size_t *)samples {
    return _GB->runFor(videoBuffer, pitch, audioBuffer, *samples);
}

- (void)reset {
    _GB->reset();
}

- (void)resetWithFlags:(LoadFlags)flags {
    _GB->resetWithFlags(flags);
}

- (void)setDMGPaletteColorForPaletteNo:(int)paletteNo colorNo:(int)colorNo to:(unsigned long)rgb32 {
    _GB->setDmgPaletteColor(paletteNo, colorNo, rgb32);
}

- (void)setInputGetter:(id<InputGetterProtocol>)getInput {
    delete _internalInputGetter;
    _internalInputGetter = new InputGetterBridge(getInput);
    
    _GB->setInputGetter(_internalInputGetter);
}

- (BOOL)supportsGBC {
    return _GB->isCgb();
}

- (BOOL)isLoaded {
    return _GB->isLoaded();
}

- (void)saveSaveData {
    _GB->saveSavedata();
}

- (BOOL)saveStateWithVideoBuffer:(uint_least32_t *)videoBuffer pitch:(ptrdiff_t)pitch error:(NSError **)error {
    bool result = _GB->saveState(videoBuffer, pitch);
    
    if (!result && error) {
        *error = [NSError new];
    }
    
    return result;
}

- (BOOL)loadStateWithError:(NSError **)error {
    bool result = _GB->loadState();
    
    if (!result && error) {
        *error = [NSError new];
    }
    
    return result;
}

- (BOOL)saveStateWithVideoBuffer:(gambatte::uint_least32_t *)videoBuffer pitch:(ptrdiff_t)pitch to:(NSURL *)stateURL error:(NSError **)error {
    std::string path = [[stateURL path] UTF8String];
    bool result = _GB->saveState(videoBuffer, pitch, path);
    
    if (!result && error) {
        *error = [NSError new];
    }
    
    return result;
}

- (BOOL)loadStateFrom:(NSURL *)stateURL error:(NSError **)error {
    std::string path = std::string([[stateURL path] UTF8String]);
    bool result = _GB->loadState(path);
    
    if (!result && error) {
        *error = [NSError new];
    }
    
    return result;
}

- (NSInteger)currentState {
    return _GB->currentState();
}

- (void)setCurrentState:(NSInteger)newState {
    return _GB->selectState((int)newState);
}

- (NSString *)ROMTitle {
    std::string title = _GB->romTitle();
    return [NSString stringWithCString:title.c_str() encoding:NSASCIIStringEncoding];
}

- (PakInfo *)pakInfo {
    gambatte::PakInfo info = _GB->pakInfo();
    return [[PakInfo alloc] initWithCppObject:&info];
}

- (void)setGameGenie:(NSString *)codes {
    _GB->setGameGenie([codes UTF8String]);
}

- (void)setGameShark:(NSString *)codes {
    _GB->setGameShark([codes UTF8String]);
}

- (BOOL)loadDMGBootROM:(NSURL *)url {
    return _GB->setDmgBootRom([[url path] UTF8String] ?: "");
}

@end
