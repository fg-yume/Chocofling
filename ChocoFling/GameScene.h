//
//  MyScene.h
//  ChocoFling
//

//  Copyright (c) 2014 Desu Ex Machina. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class ViewController;

// Enum for collider bit masks
typedef enum : uint8_t {
    ColliderTypeFondue = 1,
    ColliderTypeFood = 2,
    ColliderTypeNonFood = 4,
    ColliderTypePowerUp = 8
}ColliderType;

@interface GameScene : SKScene<SKPhysicsContactDelegate>
@property(nonatomic, weak)ViewController *viewController;

- (void)resetGame;

@end
