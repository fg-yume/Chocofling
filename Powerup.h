//
//  Powerup.h
//  ChocoFling
//
//  Created by Freddy Garcia on 2/1/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import "FallingObject.h"

typedef enum
{
    kChocolateBar,
    kCaramel,
    kBottledWater,
    kDietaryPlan,
    kClock
}PowerupType;

@interface Powerup : FallingObject

@property PowerupType type;

-(id)initWithTexture:(SKTexture *)texture andSpeed:(SpeedType)speed andPowerupType:(PowerupType)type;

@end
