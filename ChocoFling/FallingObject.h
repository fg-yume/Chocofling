//
//  FallingObject.h
//  ChocoFling
//
//  Created by Freddy Garcia on 1/30/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum
{
    kSlow,
    kNormal,
    kFast,
}SpeedType;

@interface FallingObject : SKSpriteNode

@property BOOL isPowerup;
@property BOOL isFood;
@property short value;

-(id)initWithTexture:(SKTexture *)texture andSpeed:(SpeedType)speed andPointValue:(short)value isFood:(BOOL)isFood isPowerup:(BOOL)isPowerup;

@end
