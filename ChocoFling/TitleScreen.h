//
//  TitleScreen.h
//  ChocoFling
//
//  Created by Student on 1/30/14.
//  Copyright (c) 2014 Desu Ex Machina. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class ViewController;

@interface TitleScreen : SKScene
@property(nonatomic, weak)ViewController *viewController;
-(void)runStartScreenTransition;

@end
