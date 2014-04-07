//
//  Powerup.m
//  ChocoFling
//
//  Created by Freddy Garcia on 2/1/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import "Powerup.h"

@implementation Powerup

/*
 * Custom initialization that forgoes many of the parameters for its
 * parent since certain values are the same for all powerups
 */
-(id)initWithTexture:(SKTexture *)texture andSpeed:(SpeedType)speed andPowerupType:(PowerupType)type
{
    self = [super initWithTexture:texture andSpeed:speed andPointValue:0 isFood:false isPowerup:true];
    
    self.type = type;
    
    return self;
}

@end
