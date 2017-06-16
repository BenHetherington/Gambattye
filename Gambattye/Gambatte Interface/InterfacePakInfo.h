//
//  InterfacePakInfo.h
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
#import "libgambatte/include/pakinfo.h"
#endif

@interface PakInfo : NSObject

@property (readonly, getter=isHeaderChecksumValid) BOOL headerChecksumValid;
@property (readonly, getter=MBC) NSString *MBC;
@property (readonly, getter=RAMBanks) unsigned RAMBanks;
@property (readonly, getter=ROMBanks) unsigned ROMBanks;

#ifdef __cplusplus
- (instancetype)initWithCppObject:(gambatte::PakInfo *)pakInfo;
#endif
//- (instancetype)init;
//- (instancetype)initWithMultiPak:(BOOL)multiPak ROMBanks:(unsigned)ROMBanks ROMHeader:(unsigned char[])ROMHeader;

@end
