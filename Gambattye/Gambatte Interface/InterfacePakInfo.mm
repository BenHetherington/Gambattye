//
//  InterfacePakInfo.mm
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. All rights reserved.
//

#import "InterfacePakInfo.h"
#import "libgambatte/include/pakinfo.h"

@interface PakInfo ()

@property (assign) gambatte::PakInfo *info;

@end

@implementation PakInfo

- (instancetype)initWithCppObject:(gambatte::PakInfo *)pakInfo {
    self = [super init];
    if (self) {
        _info = pakInfo;
    }
    return self;
}
//
//- (instancetype)init
//{
//    return [self initWithCppObject:new gambatte::PakInfo()];
//}
//
//- (instancetype)initWithMultiPak:(BOOL)multiPak ROMBanks:(unsigned int)ROMBanks ROMHeader:(unsigned char [])ROMHeader {
//    return [self initWithCppObject:new gambatte::PakInfo(multiPak, ROMBanks, ROMHeader)];
//}

- (BOOL)isHeaderChecksumValid {
    return _info->headerChecksumOk();
}

- (NSString *)MBC {
    return [NSString stringWithCString:_info->mbc().c_str() encoding:NSASCIIStringEncoding];
}

- (unsigned)RAMBanks {
    return _info->rambanks();
}

- (unsigned)ROMBanks {
    return _info->rombanks();
}

//- (void)dealloc {
//    delete _info;
//}

@end
