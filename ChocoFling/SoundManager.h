//
//  SoundManager.h
//  ChocoFling
//
//  Created by Steven Shing on 2/2/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

static NSString* const kTitleBgm = @"Chocolate_Village";
static NSString* const kGameBgm = @"The_Bakery";
static NSString* const kSplatSound = @"splat";
static NSString* const kPowerupSound = @"powerup";

@interface SoundManager : NSObject
- (void) playSoundEffect:(NSString *)fileName;
- (void) playBackground: (int) gameState;
- (void) stopBackground;
@end
