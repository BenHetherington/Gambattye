//
//  GB.h
//  Gambattye
//
//  Created by Ben10do on 29/01/2017.
//  Copyright © 2017 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

#import <Foundation/Foundation.h>
#import "InterfacePakInfo.h"
#import "InterfaceInputGetter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GB : NSObject

/** True if the currently loaded ROM image is treated as having CGB support. */
@property (readonly, getter=supportsGBC) BOOL supportsGBC;

/** True if a ROM image is loaded. */
@property (readonly, getter=isLoaded) BOOL loaded;

/**
 * Selects which state slot to save state to or load state from, and returns the currently selected slot.
 * There are 10 such slots, numbered from 0 to 9 (periodically extended for all n).
 */
@property (getter=currentState, setter=setCurrentState:) NSInteger currentState;

/** ROM header title of currently loaded ROM image. */
@property (readonly, getter=ROMTitle) NSString *ROMTitle;

/** GamePak/Cartridge info. */
@property (readonly, getter=pakInfo) PakInfo *pakInfo;

// Redefined explicitly, to ensure usability from Swift without having to reference any C++ types
typedef NS_OPTIONS(int, LoadFlags) {
    LoadFlagsForceDMG = 1,
    LoadFlagsUseGBA = 2,
    LoadFlagsMulticart = 4
};

/*
 * Load ROM image.
 *
 * @param ROMURL   Path to rom image file. Typically a .gbc or .gb file.
 * @param flags    ORed combination of LoadFlags.
 * @return YES on success, NO on failure.
 */
- (BOOL)loadFrom:(NSURL *)ROMURL flags:(LoadFlags)flags error:(NSError **)error;

/**
 * Emulates until at least 'samples' audio samples are produced in the
 * supplied audio buffer, or until a video frame has been drawn.
 *
 * There are 35112 audio (stereo) samples in a video frame.
 * May run for up to 2064 audio samples too long.
 *
 * An audio sample consists of two native endian 2s complement 16-bit PCM samples,
 * with the left sample preceding the right one. Usually casting audioBuf to
 * int16_t* is OK. The reason for using an uint_least32_t* in the interface is to
 * avoid implementation-defined behavior without compromising performance.
 * libgambatte is strictly c++98, so fixed-width types are not an option (and even
 * c99/c++11 cannot guarantee their availability).
 *
 * Returns early when a new video frame has finished drawing in the video buffer,
 * such that the caller may update the video output before the frame is overwritten.
 * The return value indicates whether a new video frame has been drawn, and the
 * exact time (in number of samples) at which it was completed.
 *
 * @param videoBuffer 160x144 RGB32 (native endian) video frame buffer or 0
 * @param pitch distance in number of pixels (not bytes) from the start of one line
 *              to the next in videoBuf.
 * @param audioBuffer buffer with space >= samples + 2064
 * @param samples  in: number of stereo samples to produce,
 *                out: actual number of samples produced
 * @return sample offset in audioBuf at which the video frame was completed, or -1
 *         if no new video frame was completed.
 */
- (ptrdiff_t)runWithVideoBuffer:(uint_least32_t *)videoBuffer pitch:(ptrdiff_t)pitch audioBuffer:(uint_least32_t *)audioBuffer samples:(size_t *)samples;

/**
 * Reset to initial state.
 * Equivalent to reloading a ROM image, or turning a Game Boy Color off and on again.
 */
- (void)reset;

/**
 * Reset to initial state, using the given LoadFlags.
 * Equivalent to reloading a ROM image, or turning a Game Boy Color off and on again.
 *
 * @param flags    ORed combination of LoadFlags
 */
- (void)resetWithFlags:(LoadFlags)flags;

/**
 * @param paletteNo 0 <= palNum < 3. One of BG_PALETTE, SP1_PALETTE and SP2_PALETTE.
 * @param colorNo 0 <= colorNum < 4
 */
- (void)setDMGPaletteColorForPaletteNo:(int)paletteNo colorNo:(int)colorNo to:(unsigned long)rgb32;

/** Sets the callback used for getting input state. */
- (void)setInputGetter:(id<InputGetterProtocol>)getInput;

/** Writes persistent cartridge data to disk. Done implicitly on ROM close. */
- (void)saveSaveData;

/**
 * Saves emulator state to the state slot selected with currentState.
 * The data will be stored in the directory given by setSaveDir().
 *
 * @param  videoBuffer 160x144 RGB32 (native endian) video frame buffer or 0. Used for
 *                     saving a thumbnail.
 * @param  pitch distance in number of pixels (not bytes) from the start of one line
 *               to the next in videoBuf.
 * @return success
 */
- (BOOL)saveStateWithVideoBuffer:(uint_least32_t *)videoBuffer pitch:(ptrdiff_t)pitch error:(NSError **)error;

/**
 * Loads emulator state from the state slot selected with currentState.
 * @return success
 */
- (BOOL)loadStateWithError:(NSError **)error;

/**
 * Saves emulator state to the file given by 'filepath'.
 *
 * @param  videoBuffer 160x144 RGB32 (native endian) video frame buffer or 0. Used for
 *                     saving a thumbnail.
 * @param  pitch distance in number of pixels (not bytes) from the start of one line
 *               to the next in videoBuf.
 * @return success
 */
- (BOOL)saveStateWithVideoBuffer:(uint_least32_t *)videoBuffer pitch:(ptrdiff_t)pitch to:(NSURL *)stateURL error:(NSError **)error;

/**
 * Loads emulator state from the file given by 'filepath'.
 * @return success
 */
- (BOOL)loadStateFrom:(NSURL *)stateURL error:(NSError **)error;

/**
 * Set Game Genie codes to apply to currently loaded ROM image. Cleared on ROM load.
 * @param codes Game Genie codes in format HHH-HHH-HHH;HHH-HHH-HHH;... where
 *              H is [0-9]|[A-F]
 */
- (void)setGameGenie:(NSString *)codes;

/**
 * Set Game Shark codes to apply to currently loaded ROM image. Cleared on ROM load.
 * @param codes Game Shark codes in format 01HHHHHH;01HHHHHH;... where H is [0-9]|[A-F]
 */
- (void)setGameShark:(NSString *)codes;

@end

NS_ASSUME_NONNULL_END
