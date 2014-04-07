//
//  InstructionScreen.m
//  ChocoFling
//
//  Created by Student on 1/30/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import "InstructionScreen.h"
#import "ViewController.h"

@implementation InstructionScreen
{
    BOOL _contentCreated;
}

- (void)didMoveToView:(SKView *)view
{
    if(!_contentCreated)
    {
        [self createSceneContents];
        _contentCreated = YES;
    }
}


-(void)createSceneContents
{
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"howtoscreen.png"]];
    background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    background.size = CGSizeMake(768, 1024);
    [self addChild:background];
    self.scaleMode = SKSceneScaleModeAspectFit;
    //[self addChild:[self createTextNode]];
}

-(SKLabelNode *)createTextNode
{
    SKLabelNode *textNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    textNode.name = @"textNode";
    textNode.text = @"Instructions testing";
    textNode.fontSize = 48;
    CGPoint position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - (self.frame.size.height * 1/3));
    textNode.position = position;
    
    return textNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    for(touch in touches)
    {
        self.viewController.gameState = kGameStateTitle;
        [self.viewController showTitleScene];
    }
}

- (void)dealloc{
    // blah blah
}


@end
