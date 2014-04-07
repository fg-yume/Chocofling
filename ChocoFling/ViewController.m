//
//  ViewController.m
//  ChocoFling
//
//  Created by Steven Shing on 1/30/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import "ViewController.h"
@interface ViewController()
@property (weak, nonatomic) IBOutlet UIButton *playGameButton;
@property (weak, nonatomic) IBOutlet UIButton *instructionButton;
@property (weak, nonatomic) IBOutlet UIButton *creditButton;
@property (weak, nonatomic) SKView *skView;
@end

@implementation ViewController
{
    SoundManager *_soundManager;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // loading property list
    NSString* path = [[NSBundle mainBundle] pathForResource:@"GameData" ofType:@"plist"];
    self.gameData = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    // initialize the sound manager
    _soundManager = [[SoundManager alloc] init];
    
    // Present the title scene
    if(self.gameState == kGameStateTitle)
        [self.skView presentScene:self.titleScene];
}

// lazy loading prep
- (SKView *)skView
{
    if(!_skView)
    {
        _skView = (SKView *)self.view;
    }
    return _skView;
}

// scenes
- (TitleScreen *)titleScene
{
    if(!_titleScene)
    {
        _titleScene = [TitleScreen sceneWithSize: self.skView.bounds.size];
        _titleScene.scaleMode = SKSceneScaleModeAspectFit;
        //_titleScene.backgroundColor = [SKColor blueColor];
        [_soundManager playBackground: kGameStateTitle];
        _titleScene.viewController = self;
    }
    
    return _titleScene;
}

- (InstructionScreen *)instructionScene
{
    if(!_instructionScene)
    {
        _instructionScene = [InstructionScreen sceneWithSize: self.skView.bounds.size];
        _instructionScene.scaleMode = SKSceneScaleModeAspectFit;
        //_instructionScene.backgroundColor = [SKColor purpleColor];
        _instructionScene.viewController = self;
    }
    
    return _instructionScene;
}

- (GameScene *)gameScene
{
    if(!_gameScene)
    {
        _gameScene = [GameScene sceneWithSize: self.skView.bounds.size];
        _gameScene.scaleMode = SKSceneScaleModeAspectFit;
        //[_soundManager playBackground: kGameStateGame];
        _gameScene.viewController = self;
    }
    
    return _gameScene;
}

- (CreditScreen *)creditScene
{
    if(!_creditScene)
    {
        _creditScene = [CreditScreen sceneWithSize: self.skView.bounds.size];
        _creditScene.scaleMode = SKSceneScaleModeAspectFit;
        //_creditScene.backgroundColor = [SKColor grayColor];
        _creditScene.viewController = self;
    }
    
    return _creditScene;
}

- (GameOverScreen *)gameOverScene
{
    if(!_gameOverScene)
    {
        _gameOverScene = [GameOverScreen sceneWithSize: self.skView.bounds.size];
        _gameOverScene.scaleMode = SKSceneScaleModeAspectFit;
        // stop the music
        [_soundManager stopBackground];
        _gameOverScene.viewController = self;
    }
    
    return _gameOverScene;
}


// Display these scenes
- (void)showTitleScene
{
    [self.skView presentScene: self.titleScene];
    [self hideUIElements: NO];
}

- (void)showTitleSceneAndResetBg
{
    [self.skView presentScene: self.titleScene];
    [_soundManager playBackground: kGameStateTitle];
    [self hideUIElements: NO];
}

- (void)showInstructionScene
{
    [self.skView presentScene: self.instructionScene];
}

- (void)showCreditScene
{
    [self.skView presentScene: self.creditScene];
}

-(void)showGameScene
{
    [_gameScene resetGame];
    [self.skView presentScene:self.gameScene];
}

// What to do when buttons are pressed
- (IBAction)clickPlayButton
{
    self.gameState = kGameStateGame;
    
    [_gameScene resetGame];
    [_soundManager playBackground:kGameStateGame];
    [self hideUIElements: YES];
}

- (IBAction)clickInstructionButton
{
    self.gameState = kGameStateInstructions;
    [self hideUIElements: YES];
}

- (IBAction)clickCreditButton
{
    self.gameState = kGameStateCredits;
    [self hideUIElements: YES];
}

- (void)showGameOverScene
{
    [_soundManager stopBackground];
    [self.skView presentScene: self.gameOverScene];
}

// Hide buttons when transitioning
- (void)hideUIElements:(BOOL)shouldHide
{
    CGFloat alpha = shouldHide ? 0.0f : 1.0f;
        
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
        self.playGameButton.alpha = alpha;
        self.instructionButton.alpha = alpha;
        self.creditButton.alpha = alpha;
        
        if (self.gameState == kGameStateGame)
            [self.titleScene runStartScreenTransition];
        
        if (self.gameState == kGameStateInstructions)
            [self.titleScene runStartScreenTransition];
        
        if (self.gameState == kGameStateCredits)
            [self.titleScene runStartScreenTransition];
    }
     
    completion: NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

// Hide the status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
