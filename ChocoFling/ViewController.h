//
//  ViewController.h
//  ChocoFling
//

//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "TitleScreen.h"
#import "InstructionScreen.h"
#import "CreditScreen.h"
#import "GameScene.h"
#import "GameOverScreen.h"
#import "SoundManager.h"

typedef enum {
    kGameStateTitle,
    kGameStateInstructions,
    kGameStateCredits,
    kGameStateGame,
    kGameStateGameOver
} GameState;

@interface ViewController : UIViewController
@property(nonatomic, strong) TitleScreen *titleScene;
@property(nonatomic, strong) InstructionScreen *instructionScene;
@property(nonatomic, strong) CreditScreen *creditScene;
@property(nonatomic, strong) GameScene *gameScene;
@property(nonatomic, strong) GameOverScreen *gameOverScene;
@property(nonatomic) GameState gameState;
@property (strong, nonatomic) NSDictionary* gameData; // property list

- (IBAction)clickPlayButton;
- (void)showTitleScene;
- (void)showTitleSceneAndResetBg;
- (void)showGameOverScene;
- (void)showGameScene;

@end
