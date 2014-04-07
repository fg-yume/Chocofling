//
//  TitleScreen.m
//  ChocoFling
//
//  Created by Student on 1/30/14.
//  Copyright (c) 2014 Desu Ex Machina. All rights reserved.
//

#import "TitleScreen.h"
#import "ViewController.h"

@implementation TitleScreen
{
    BOOL _contentCreated;
}

-(void)didMoveToView:(SKView *)view
{
    if(!_contentCreated)
    {
        [self createSceneContents];
        _contentCreated = YES;
    }
}

- (void)willMoveFromView:(SKView *)view
{
    [super willMoveFromView:view];
}


-(void)createSceneContents
{
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"titlescreen.png"]];
    background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    background.size = CGSizeMake(768, 1024);
    [self addChild:background];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild:[self createTitleNode]];
}

-(SKLabelNode *)createTitleNode
{
    SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    titleNode.name = @"titleNode";
    titleNode.text = @"";
    titleNode.fontSize = 60;
    CGPoint titlePosition = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - (self.frame.size.height * 1/3));
    titleNode.position = titlePosition;
    
    return titleNode;
}

-(void)runStartScreenTransition
{
    SKNode *titleNode = [self childNodeWithName:@"titleNode"];
    SKAction *zoomIn = [SKAction scaleTo: 2.0 duration: .5];
    SKAction *zoomOut = [SKAction scaleTo: 1.0 duration: .3];
    
    SKAction *allActions = [SKAction sequence:@[zoomIn, zoomOut]];
    [titleNode runAction: allActions completion:^
    {
        if (self.viewController.gameState == kGameStateGame)
            [self.view presentScene:self.viewController.gameScene];
        
        if (self.viewController.gameState == kGameStateInstructions)
            [self.view presentScene:self.viewController.instructionScene];
        
        if (self.viewController.gameState == kGameStateCredits)
            [self.view presentScene:self.viewController.creditScene];
    }];
}


@end
