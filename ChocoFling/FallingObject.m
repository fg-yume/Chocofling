//
//  FallingObject.m
//  ChocoFling
//
//  Created by Freddy Garcia on 1/30/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import "FallingObject.h"

@interface FallingObject()

// private properties
@property (nonatomic) SpeedType speed;

@end

@implementation FallingObject

/*
 * Initialization with basic properties defined in the parameters
 */
- (id)initWithTexture:(SKTexture *)texture andSpeed:(SpeedType)speed andPointValue:(short)value isFood:(BOOL)isFood isPowerup:(BOOL)isPowerup
{
    if(self = [super initWithTexture:texture])
    {
        // setting properties
        self.name = @"fallingObject";
        self.speed = speed;
        self.isPowerup = isPowerup;
        self.isFood = isFood;
        self.value = value;
    }
    
    return self;
}

#ifdef DEBUG
/*
 * Inform us that the FallingObject has been removed
 */
/*
- (void)removeFromParent
{
    NSLog(@"Removing falling object from parent!");

    [super removeFromParent];
}*/
#endif

/*
 * Overrides the description of the object
 * This can be retrieved by NSLogging the object
 */
- (NSString *)description
{
    NSMutableString* desc;
    
    // speed
    if(self.speed == kSlow)
        [desc stringByAppendingString:@"Speed: slow\n"];
    
    else if(self.speed == kNormal)
        [desc stringByAppendingString:@"Speed: normal\n"];
    
    else
        [desc stringByAppendingString:@"Speed: fast\n"];
    
    // whether or not it is power up
    if(self.isPowerup)
        [desc stringByAppendingString:@"Is powerup: Yes\n"];
    else
        [desc stringByAppendingString:@"Is powerup: No\n"];
    
    // whether or not it is food
    if(self.isFood)
        [desc stringByAppendingString:@"Is food: Yes\n"];
    else
        [desc stringByAppendingString:@"Is food: No\n"];
    
    // return description of the FallingObject
    return desc;
}

@end
