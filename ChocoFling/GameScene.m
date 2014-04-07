//
//  MyScene.m
//  ChocoFling
//
//  Created by Student on 1/30/14.
//  Copyright (c) 2014 Desu Ex Machina. All rights reserved.
//

#import "GameScene.h"
#import "ViewController.h"
#import "FallingObject.h"
#import "Powerup.h"
#import "SoundManager.h"

const float IPAD_GRAVITATIONAL_ACCEL = -1.5;
const float IPAD_MAX_LAUNCH_IMPULSE = 4.1;
const int IPAD_FONDUE_SIDE_SIZE = 12;
const float IPAD_LAUNCH_IMPULSE_SKEW = 300.0;
const int MAX_FONDUE = 200;
const int MAX_SCORE = 999999999;
const float HUD_HEIGHT = 160.0;
const float POWERUP_INDICATION_SIZE = 40.0;
const float POWERUP_INDICATION_RECT_WIDTH = 25.0;
const float SQUARE_OBJECT_SIZE = 60.0;
const float RECT_OBJECT_SIZE_WIDTH = 40.0;
const float RECT_OBJECT_SIZE_HEIGHT = 70.0;

// object spawn limits
const float MIN_OBJECTSPAWN_TIME = 1.0f;
const float MAX_OBJECTSPAWN_TIME = 2.0f;

// power-up spawn limits
const float MIN_POWERUPSPAWN_TIME = 5.0f;
const float MAX_POWERUPSPAWN_TIME = 10.0f;

// Game states
typedef enum
{
    kChocolateState,
    kWaterState,
    kDoneState
}ChocoFlipStage;

@implementation GameScene
{
    int _fondueSideSize;
    int _currentFondue;
    int _fondueMultiplier;
    
    // to determine direction of impulse
    CGPoint _startSwipePos;
    CGPoint _endSwipePos;
    
    // physics
    float _gravitationalAccel;
    float _launchImpulse;
    float _launchImpulseSkew;
    
    // spawn timers
    double _lastObjectSpawnTime;
    double _lastPowerupSpawnTime;
    
    // Score
    int _score;
    int _highScore;
    int _scoreMultiplier;
    
    // global speeds
    short _speedMultiplier;
    
    // state
    ChocoFlipStage currentState;
    
    // labels
    SKLabelNode* _scoreLabel;
    SKLabelNode* _highScoreLabel;
    SKLabelNode* _fondueLabel;
    SKLabelNode* _scoreMultiplierLabel;
    
    // textures for background
    SKTexture* _chocolateBackground;
    SKTexture* _waterBackground;
    
    SKSpriteNode* _backgroundNode;
    
    // projectile textures
    SKTexture* _fondueTexture;
    SKTexture* _waterTexture;
    
    // fondue jar
    SKTexture* _jarTexture;
    SKSpriteNode* _jar;
    SKSpriteNode* _filling;
    
    // fondue decay over time
    BOOL isDecaying;
    
    // powerup actions
    SKAction* pu_chocolateBar;
    SKAction* pu_caramel;
    SKAction* pu_bottledWater;
    SKAction* pu_dietaryPlan;
    SKAction* pu_clock;
    
    // other actions
    SKAction* splat;
    SKAction* fondueDecay;
    
    // sounds
    SoundManager *_soundManager;
    
    // Indicators for powerups
    SKSpriteNode *_powerupCaramel;
    SKTexture *_powerupCaramelTexture;
    SKSpriteNode *_powerupClock;
    SKTexture *_powerupClockTexture;
    SKSpriteNode *_powerupScale;
    SKTexture *_powerupScaleTexture;
    SKSpriteNode *_powerupWaterBottle;
    SKTexture *_powerupWaterBottleTexture;
}

#pragma mark -
#pragma mark Initialization

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        /* Setup the scene here */
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"gamescreen.png"]];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.size = CGSizeMake(768, 1024);
        [self addChild:background];
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        // defaults
        self.backgroundColor = [SKColor blackColor];
        _scoreMultiplier = 1;
        _speedMultiplier = 1;
        _fondueMultiplier = 2;
        _currentFondue = MAX_FONDUE;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _gravitationalAccel = IPAD_GRAVITATIONAL_ACCEL;
            _launchImpulse = IPAD_MAX_LAUNCH_IMPULSE;
            _fondueSideSize = IPAD_FONDUE_SIDE_SIZE;
            _launchImpulseSkew = IPAD_LAUNCH_IMPULSE_SKEW;
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            _gravitationalAccel = IPAD_GRAVITATIONAL_ACCEL;
            _launchImpulse = IPAD_MAX_LAUNCH_IMPULSE/IPAD_MAX_LAUNCH_IMPULSE;
            _fondueSideSize = IPAD_FONDUE_SIDE_SIZE/3;
            _launchImpulseSkew = IPAD_LAUNCH_IMPULSE_SKEW;
        }
        
        // Textures
        _fondueTexture = [SKTexture textureWithImageNamed:@"chocoball.png"];
        _waterTexture = [SKTexture textureWithImageNamed:@"waterdrip.png"];
        _powerupCaramelTexture = [SKTexture textureWithImageNamed:@"caramel.png"];
        _powerupClockTexture = [SKTexture textureWithImageNamed:@"clock.png"];
        _powerupScaleTexture = [SKTexture textureWithImageNamed:@"scale.png"];
        _powerupWaterBottleTexture = [SKTexture textureWithImageNamed:@"waterbottle.png"];
        
        // Customize the gravity of the world
        self.physicsWorld.gravity = CGVectorMake(0.0, _gravitationalAccel);
        self.physicsWorld.contactDelegate = self;
        
        // current state set to chocolate
        currentState = kChocolateState;
        
        _soundManager = [[SoundManager alloc] init];
        
        // jar of fondue
        _jarTexture = [SKTexture textureWithImageNamed:@"jar.png"];
        _jar = [[SKSpriteNode alloc] initWithTexture:_jarTexture];
        _jar.size = CGSizeMake(60, 100);
        _jar.position = CGPointMake(self.frame.size.width/2, _jar.size.height/2);
        
        // filling in the jar
        _filling = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(54, 72)];
        _filling.name = @"filling";
        _filling.position = CGPointMake(self.frame.size.width/2, 7);
        _filling.anchorPoint = CGPointMake(.5, 0);
        
        [self addChild:_filling];
        [self addChild:_jar];
        
        // adding powerup icons
        _powerupCaramel = [[SKSpriteNode alloc] initWithTexture:_powerupCaramelTexture color:[SKColor brownColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        _powerupCaramel.name = @"powerupCaramel";
        _powerupCaramel.position = CGPointMake(CGRectGetMidX(self.frame) - POWERUP_INDICATION_SIZE, self.frame.size.height - 120);
        
        _powerupClock = [[SKSpriteNode alloc] initWithTexture:_powerupClockTexture color:[SKColor brownColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        _powerupClock.name = @"powerupClock";
        _powerupClock.position = CGPointMake(CGRectGetMidX(self.frame) + POWERUP_INDICATION_SIZE, self.frame.size.height - 120);
        
        _powerupScale = [[SKSpriteNode alloc] initWithTexture:_powerupScaleTexture color:[SKColor brownColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        _powerupScale.name = @"powerupScale";
        _powerupScale.position = CGPointMake(CGRectGetMidX(self.frame) - 3*POWERUP_INDICATION_SIZE, self.frame.size.height - 120);
        
        _powerupWaterBottle = [[SKSpriteNode alloc] initWithTexture:_powerupWaterBottleTexture color:[SKColor cyanColor] size:CGSizeMake(POWERUP_INDICATION_RECT_WIDTH, POWERUP_INDICATION_SIZE)];
        _powerupWaterBottle.name = @"powerupWaterBottle";
        _powerupWaterBottle.position = CGPointMake(CGRectGetMidX(self.frame) + 3*POWERUP_INDICATION_SIZE, self.frame.size.height - 120);
        
        [self addChild:_powerupCaramel];
        [self addChild:_powerupClock];
        [self addChild:_powerupScale];
        [self addChild:_powerupWaterBottle];
        
        [self createTextNodes];
        [self createActions];
    }

    return self;
}

/*
 * Reset the game prior to it being shown
 */
- (void)resetGame
{
    NSLog(@"reset called!");
    // Remove flungFondue if it exits the screen on the sides or the bottom
    [self enumerateChildNodesWithName:@"flungFondue" usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node removeFromParent];
     }];
    // Remove fallingObjects if it exits the screen on the sides or the bottom
    [self enumerateChildNodesWithName:@"fallingObject" usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node removeFromParent];
     }];
    
    _currentFondue = MAX_FONDUE;
    _score = 0;
    _scoreMultiplier = 1;
    _speedMultiplier = 1;
    _fondueMultiplier = 2;

    
    currentState = kChocolateState;
}

/*
 * Initializes all of the SKActions, creating sequences which
 * will be run by the scene when a collision occurs with the corresponding
 * powerup
 */
- (void)createActions
{
    // power-up effects
    SKAction* pu_chocolateBar_increaseChocolate;
    
    SKAction* pu_caramel_increaseScoreMultiplier;
    SKAction* pu_caramel_wait;
    SKAction* pu_caramel_decreaseScoreMultiplier;
    
    SKAction* pu_bottledWater_changeToWaterState;
    SKAction* pu_bottledWater_wait;
    SKAction* pu_bottledWater_changeToChocolateState;
    
    SKAction* pu_dietaryPlan_decreaseFondueMultiplier;
    SKAction* pu_dietaryPlan_wait;
    SKAction* pu_dietaryPlan_increaseFondueMultiplier;
    
    SKAction* pu_clock_decreaseSpeedMultiplier;
    SKAction* pu_clock_wait;
    SKAction* pu_clock_increaseSpeedMultiplier;
    
    SKAction* splat_wait;
    SKAction* splat_remove;
    
    SKAction* fondueDecay_decreaseFondue;
    SKAction* fondueDecay_wait;
    SKAction* fondueDecay_loop;
    
    // chocolate bar: increases fondue by 20
    pu_chocolateBar_increaseChocolate = [SKAction runBlock:^{
        _currentFondue += 20;
        
        // don't go over max
        if(_currentFondue > MAX_FONDUE)
            _currentFondue = MAX_FONDUE;
    }];
    
    // caramel: multiplies score by x2 for a certain time
    pu_caramel_increaseScoreMultiplier = [SKAction runBlock:^{
        _scoreMultiplier *= 2;
        //NSLog(@"Score multiplier is now %d", _scoreMultiplier);
        
        // Timer that indicates how long remains on the powerup effect
        SKSpriteNode* timer = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        timer.alpha = 0.7;
        timer.position = CGPointMake(CGRectGetMidX(self.frame) - POWERUP_INDICATION_SIZE, self.frame.size.height - 120 - timer.size.height/2);
        timer.anchorPoint = CGPointMake(.5, 0);
        
        [self addChild:timer];
        
        // decrease size of the bar over time and then remove it
        [timer runAction:[SKAction scaleYTo:0.0 duration:5] completion:^{
            [timer removeFromParent];
        }];
    }];
    pu_caramel_wait = [SKAction waitForDuration:10];
    pu_caramel_decreaseScoreMultiplier = [SKAction runBlock:^{
        _scoreMultiplier /= 2;
        //NSLog(@"Score multiplier is now %d", _scoreMultiplier);
    }];
    
    // bottled water
    pu_bottledWater_changeToWaterState = [SKAction runBlock:^{
        currentState = kWaterState;
        //NSLog(@"Current state is now %d", currentState);
        
        // Timer that indicates how long remains on the powerup effect
        SKSpriteNode* timer = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        timer.alpha = 0.7;
        timer.position = CGPointMake(CGRectGetMidX(self.frame) + 3 * POWERUP_INDICATION_SIZE, self.frame.size.height - 120 - timer.size.height/2);
        timer.anchorPoint = CGPointMake(.5, 0);
        
        [self addChild:timer];
        
        // decrease size of the bar over time and then remove it
        [timer runAction:[SKAction scaleYTo:0.0 duration:5] completion:^{
            [timer removeFromParent];
        }];
    }];
    pu_bottledWater_wait = [SKAction waitForDuration:20];
    pu_bottledWater_changeToChocolateState = [SKAction runBlock:^{
        currentState = kChocolateState;
        //NSLog(@"Current state is now %d", currentState);
    }];
    
    // dietaryplan
    pu_dietaryPlan_decreaseFondueMultiplier = [SKAction runBlock:^{
        _fondueMultiplier /= 2;
        
        // NSLog(@"Fondue multiplier is now %d", _fondueMultiplier);
        
        // Timer that indicates how long remains on the powerup effect
        SKSpriteNode* timer = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        timer.alpha = 0.7;
        timer.position = CGPointMake(CGRectGetMidX(self.frame) - 3 * POWERUP_INDICATION_SIZE, self.frame.size.height - 120 - timer.size.height/2);
        timer.anchorPoint = CGPointMake(.5, 0);
        
        [self addChild:timer];
        
        // decrease size of the bar over time and then remove it
        [timer runAction:[SKAction scaleYTo:0.0 duration:5] completion:^{
            [timer removeFromParent];
        }];
    }];
    pu_dietaryPlan_wait = [SKAction waitForDuration:15];
    pu_dietaryPlan_increaseFondueMultiplier = [SKAction runBlock:^{
        _fondueMultiplier *= 2;
        //NSLog(@"Fondue multiplier is now %d", _fondueMultiplier);
    }];
    
    // clock
    pu_clock_increaseSpeedMultiplier = [SKAction runBlock:^{
        // change speed multiplier for new items that spawn within the clock's timeframe
        _speedMultiplier *= 2;
        //NSLog(@"Speed multiplier is now %d", _speedMultiplier);
        
        // Timer that indicates how long remains on the powerup effect
        SKSpriteNode* timer = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(POWERUP_INDICATION_SIZE, POWERUP_INDICATION_SIZE)];
        timer.alpha = 0.7;
        timer.position = CGPointMake(CGRectGetMidX(self.frame) + POWERUP_INDICATION_SIZE, self.frame.size.height - 120 - timer.size.height/2);
        timer.anchorPoint = CGPointMake(.5, 0);
        
        [self addChild:timer];
        
        // decrease size of the bar over time and then remove it
        [timer runAction:[SKAction scaleYTo:0.0 duration:15] completion:^{
            [timer removeFromParent];
        }];
    }];
    pu_clock_wait = [SKAction waitForDuration:5];
    pu_clock_decreaseSpeedMultiplier = [SKAction runBlock:^{
        _speedMultiplier /= 2;
        //NSLog(@"Speed multiplier is now %d", _speedMultiplier);
    }];
    
    // splat
    splat_wait = [SKAction waitForDuration:0.25];
    splat_remove = [SKAction removeFromParent];
    
    // fondue decay
    fondueDecay_wait = [SKAction waitForDuration:1.5];
    fondueDecay_decreaseFondue = [SKAction runBlock:^{
        _currentFondue -= 1;
    }];
    fondueDecay_loop = [SKAction sequence:@[fondueDecay_wait,fondueDecay_decreaseFondue]];
    
    /* sequences */
    pu_chocolateBar = [SKAction sequence:@[pu_chocolateBar_increaseChocolate]];
    pu_caramel = [SKAction sequence:@[pu_caramel_increaseScoreMultiplier, pu_caramel_wait, pu_caramel_decreaseScoreMultiplier]];
    pu_bottledWater = [SKAction sequence:@[pu_bottledWater_changeToWaterState, pu_bottledWater_wait, pu_bottledWater_changeToChocolateState]];
    pu_dietaryPlan = [SKAction sequence:@[pu_dietaryPlan_decreaseFondueMultiplier, pu_dietaryPlan_wait, pu_dietaryPlan_increaseFondueMultiplier]];
    pu_clock = [SKAction sequence:@[pu_clock_increaseSpeedMultiplier, pu_clock_wait, pu_clock_decreaseSpeedMultiplier]];
    splat = [SKAction sequence:@[splat_wait, splat_remove]];
    fondueDecay = [SKAction repeatActionForever:fondueDecay_loop];
}

-(void)createTextNodes
{
	// player score text node
    // text label
    SKLabelNode *textNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    
    textNode.fontColor = [SKColor blackColor];
    textNode.name = @"scoreText";
    textNode.text = @"Score: x";
    textNode.fontSize = 30.0;
    textNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    CGPoint textPosition = CGPointMake(45.0, self.frame.size.height - 50.0);
    
    textNode.position = textPosition;
    [self addChild: textNode];
    
    // Score multiplier
    _scoreMultiplierLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    _scoreMultiplierLabel.fontColor = [SKColor blackColor];
    _scoreMultiplierLabel.name = @"scoreMultiplierLabel";
    _scoreMultiplierLabel.text = @"1";
    _scoreMultiplierLabel.fontSize = 30.0;
    _scoreMultiplierLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    textPosition = CGPointMake(142.0, self.frame.size.height - 50.0);
    
    _scoreMultiplierLabel.position = textPosition;
    [self addChild: _scoreMultiplierLabel];
    
    
    // numerical score
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    _scoreLabel.fontColor = [SKColor blackColor];
    _scoreLabel.name = @"score";
    _scoreLabel.text = @"0";
    _scoreLabel.fontSize = 30.0;
    _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    textPosition = CGPointMake(100.0, self.frame.size.height - 85.0);
    
    _scoreLabel.position = textPosition;
    [self addChild: _scoreLabel];
    
    // grab high score from NSUserDefaults if it has been set
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _highScore = [defaults integerForKey:@"highScoreKey"];
    
    // High Score text node
    textNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    textNode.fontColor = [SKColor blackColor];
    textNode.name = @"highScoreText";
    textNode.text = @"High Score:"; //[NSString stringWithFormat:@"High Score %d", _highScore];
    textNode.fontSize = 30.0;
    textNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    
    textPosition = CGPointMake(320, self.frame.size.height -50.0);
    textNode.position = textPosition;
    [self addChild: textNode];
    
    // high score
    _highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    _highScoreLabel.fontColor = [SKColor blackColor];
    _highScoreLabel.name = @"highScore";
    _highScoreLabel.text = [NSString stringWithFormat:@"%d", _highScore];
    _highScoreLabel.fontSize = 30.0;
    _highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    textPosition = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 85.0);
    
    _highScoreLabel.position = textPosition;
    [self addChild:_highScoreLabel];
    
    // fondue count
    // text label
    textNode = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    textNode.fontColor = [SKColor blackColor];
    textNode.name = @"fondueText";
    textNode.text = @"Fondue:";
    textNode.fontSize = 30.0;
    textNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    textPosition = CGPointMake(self.frame.size.width - 30.0, self.frame.size.height - 50.0);
    
    textNode.position = textPosition;
    [self addChild: textNode];
    
    //
    _fondueLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    _fondueLabel.fontColor = [SKColor blackColor];
    _fondueLabel.name = @"fondue";
    _fondueLabel.text = @"200";
    _fondueLabel.fontSize = 30.0;
    _fondueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    textPosition = CGPointMake(self.frame.size.width - 80.0, self.frame.size.height - 85.0);
    
    _fondueLabel.position = textPosition;
    [self addChild: _fondueLabel];
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(currentState != kDoneState)
    {
        /* Called when a touch begins */
        for(UITouch *touch in touches)
        {
            // Get the start position of the player's swipe
            _startSwipePos = [touch locationInNode:self];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(currentState != kDoneState)
    {
        for(UITouch *touch in touches)
        {
            // Get the end position of the player's swipe
            _endSwipePos = [touch locationInNode:self];
            // Fling fondue
            [self flingFondue];
        }
    }
}

/*
 * Creates fondue which will be flung in the direction of the user's swipe
 */
-(void)flingFondue
{
    // ONLY spawn fondue if the swipe is an upward swipe
    if(_endSwipePos.y > _startSwipePos.y)
    {
        // only decrease if in chocolate state
        if(currentState == kChocolateState)
            _currentFondue-= 1 * _fondueMultiplier;
        
        // Calculate the x and y distances between the beginning of the swipe and the end of the swipe
        float distX = _endSwipePos.x - _startSwipePos.x;
        float distY = _endSwipePos.y - _startSwipePos.y;
        // Calculate the angle to fling the fondue
        float angle = atan2f(distY, distX);
        [self makeFondue: angle distX:distX distY:distY];
    }
}

/*
 * Creates an SKSpriteNode representing fondue, and attaches a physics body as well as 
 * impulse to it
 */
- (void)makeFondue: (float)angle distX: (float)distX distY: (float)distY
{
    SKSpriteNode* fondue;
    
    // fondue texture in chocolate state
    if(currentState == kChocolateState)
        fondue = [[SKSpriteNode alloc] initWithTexture:_fondueTexture color:[SKColor brownColor] size:CGSizeMake(_fondueSideSize, _fondueSideSize)];
    
    // water texture in water state
    else if(currentState == kWaterState)
        fondue = [[SKSpriteNode alloc] initWithTexture:_waterTexture color:[SKColor blueColor] size:CGSizeMake(_fondueSideSize, _fondueSideSize)];
    
    fondue.name = @"flungFondue";
    fondue.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    fondue.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:fondue.size];
    fondue.physicsBody.friction = 0.0f;      // Remove friction
    fondue.physicsBody.allowsRotation = NO;
    fondue.physicsBody.usesPreciseCollisionDetection = YES;
    fondue.physicsBody.categoryBitMask = ColliderTypeFondue;
    fondue.physicsBody.collisionBitMask = ColliderTypeFood | ColliderTypeNonFood | ColliderTypePowerUp;
    fondue.physicsBody.contactTestBitMask = ColliderTypeFood | ColliderTypeNonFood | ColliderTypePowerUp;
    [self addChild: fondue];
    
    // IMPULSE PHYSICS
    // Skew the impulses depending on how far the person has swiped
    // The shorter the swipe, the lower the impulse applied to the fondue
    float launchImpulseX = _launchImpulse*fabs(distX/_launchImpulseSkew);
    float launchImpulseY = _launchImpulse*distY/_launchImpulseSkew;
    // Give the impulse to the fondue a max value
    if(launchImpulseX > IPAD_MAX_LAUNCH_IMPULSE)
    {
        launchImpulseX = IPAD_MAX_LAUNCH_IMPULSE;
    }
    if(launchImpulseY > IPAD_MAX_LAUNCH_IMPULSE)
    {
        launchImpulseY = IPAD_MAX_LAUNCH_IMPULSE;
    }
    // Apply the impulse to the fondue
    CGVector impulseVector = CGVectorMake(launchImpulseX * cosf(angle), launchImpulseY * sinf(angle));
    [fondue.physicsBody applyImpulse:impulseVector];
}

-(void)update:(CFTimeInterval)currentTime
{
    // while fondue remains
    if(currentState != kDoneState)
    {
        // background drawing
        [self displayBackground];
        
        // stash
        [self displayStash];
        
        // check for spawning
        bool prepareObjectSpawn = [self checkObjectSpawn];
        bool preparePowerupSpawn = [self checkPowerupSpawn];
        
        // spawn a new object if we are prepared
        if(prepareObjectSpawn)
            [self spawnObject];
        
        // spawn a new powerup if we are prepared
        if(preparePowerupSpawn)
            [self spawnPowerup];
        
        // update labels
        [self updateLabels];
        
        // decay fondue over time in chocolate state
        if(currentState == kChocolateState)
        {
            if(!isDecaying)
            {
                isDecaying = true;
                [self runAction:fondueDecay withKey:@"decayAction"];
            }
        }
        
        // stop fondue decay in water state
        else
        {
            if(isDecaying)
            {
                isDecaying = false;
                [self removeActionForKey:@"decayAction"];
            }
        }
        
        // check game over
        [self checkGameOver];
    }
}

- (void)updateLabels
{
    // display score
    _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
    
    // display score multiplier
    _scoreMultiplierLabel.text = [NSString stringWithFormat:@"%d", _scoreMultiplier];
    
    // update high score if necessary
    if(_score > _highScore)
    {
        _highScore = _score;
        _highScoreLabel.text = [NSString stringWithFormat:@"%d", _score];
    }
    
    // display fondue
    _fondueLabel.text = [NSString stringWithFormat:@"%d", _currentFondue];
}

/*
 * Checks to see if the user has run out of fondue
 */
- (void)checkGameOver
{
    if(_currentFondue <= 0)
    {
        currentState = kDoneState;
        
        // save the high score to NSUserDefaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_highScore forKey:@"highScoreKey"];
        
        // sync the data
        [defaults synchronize];
        

        // Go to the game over screen here
        self.viewController.gameState = kGameStateGameOver;
        [self.viewController showGameOverScene];
    }
}

/*
 * displays the background image in the foreground of the game
 */
- (void)displayBackground
{
    
}

/*
 * Displays the filling of the jar
 */
- (void)displayStash
{
    if(currentState == kChocolateState)
    {
        // brown filling
        _filling.color = [SKColor brownColor];
        
        // size based on amount of fondue remaining
        float percentageLeft = (float)_currentFondue / (float)MAX_FONDUE;
        
        _filling.size = CGSizeMake(54, percentageLeft * 72);
    }
    
    else if(currentState == kWaterState)
    {
        // blue filling
        _filling.color = [SKColor cyanColor];
        
        // size is max
        _filling.size = CGSizeMake(54, 72);
    }
}

#pragma mark -
#pragma mark Spawning

-(void)spawnObject
{
    // choose the object to spawn
    u_short chosenObject = [self chooseObject];
    
    SKTexture* objectTexture;
    BOOL isFood;
    short pointValue;
    CGSize objectSize;
    
    switch(chosenObject)
    {
        // banana
        case 0:
            objectTexture = [SKTexture textureWithImageNamed:@"banana.png"];
            isFood = true;
            pointValue = 20;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // cookie
        case 1:
            objectTexture = [SKTexture textureWithImageNamed:@"cookie.png"];
            isFood = true;
            pointValue = 16;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // strawberry
        case 2:
            objectTexture = [SKTexture textureWithImageNamed:@"strawberry.png"];
            isFood = true;
            pointValue = 12;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // icecream
        case 3:
            objectTexture = [SKTexture textureWithImageNamed:@"icecream.png"];
            isFood = true;
            pointValue = 16;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // pretzel
        case 4:
            objectTexture = [SKTexture textureWithImageNamed:@"pretzel.png"];
            isFood = true;
            pointValue = 16;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // umbrella
        case 5:
            objectTexture = [SKTexture textureWithImageNamed:@"cat.png"];
            isFood = false;
            pointValue = 20;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // cat
        case 6:
            objectTexture = [SKTexture textureWithImageNamed:@"umbrella.png"];
            isFood = false;
            pointValue = 16;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
           
        // cup
        case 7:
            objectTexture = [SKTexture textureWithImageNamed:@"cup.png"];
            isFood = false;
            pointValue = 12;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
           
        // frying pan
        case 8:
            objectTexture = [SKTexture textureWithImageNamed:@"frypan.png"];
            isFood = false;
            pointValue = 16;
            objectSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // spoon
        case 9:
            objectTexture = [SKTexture textureWithImageNamed:@"spoon.png"];
            isFood = false;
            pointValue = 16;
            objectSize = CGSizeMake(RECT_OBJECT_SIZE_WIDTH, RECT_OBJECT_SIZE_HEIGHT);
            break;
    }
    
    // spawn the falling object right below the HUD and at some random x-coordinate
    FallingObject* newObject = [[FallingObject alloc] initWithTexture:objectTexture andSpeed:kNormal andPointValue:pointValue isFood:isFood isPowerup:NO];
    newObject.size = objectSize;
    u_short startingXPos = arc4random_uniform(self.frame.size.width - 2*newObject.size.width) + newObject.size.width;
    newObject.position = CGPointMake(startingXPos, self.frame.size.height - HUD_HEIGHT - newObject.size.height/2);
    
    newObject.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newObject.size];
    newObject.physicsBody.friction = 0.0f;
    
    // air friction based on the speed of the object
    if(newObject.speed == kNormal)
        newObject.physicsBody.linearDamping = 0.3f * _speedMultiplier; // air friction
    
    // kFast
    else if(newObject.speed == kFast)
        newObject.physicsBody.linearDamping = 0.1f * _speedMultiplier;
    
    // kSlow
    else
        newObject.physicsBody.linearDamping = 0.5f * _speedMultiplier;
    
    newObject.physicsBody.allowsRotation = NO;
    newObject.physicsBody.usesPreciseCollisionDetection = YES;
    newObject.physicsBody.categoryBitMask = (isFood & true) ? ColliderTypeFood : ColliderTypeNonFood; // category is based on the BOOL value
    newObject.physicsBody.collisionBitMask = ColliderTypeFondue;
    newObject.physicsBody.contactTestBitMask = ColliderTypeFondue;
    
    [self addChild:newObject];
}

-(void)spawnPowerup
{
    // choose the powerup to spawn
    u_short chosenPowerup = [self choosePowerup];
    
    SKTexture* powerupTexture;
    PowerupType type;
    CGSize powerupSize;
    
    switch (chosenPowerup)
    {
        // caramel
        case 0:
            powerupTexture = [SKTexture textureWithImageNamed:@"caramel.png"];
            type = kCaramel;
            powerupSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
        
        // chocolate bar
        case 1:
            powerupTexture = [SKTexture textureWithImageNamed:@"chocobar.png"];
            powerupSize = CGSizeMake(RECT_OBJECT_SIZE_WIDTH, RECT_OBJECT_SIZE_HEIGHT);
            type = kChocolateBar;
            break;
            
        // clock
        case 2:
            powerupTexture = [SKTexture textureWithImageNamed:@"clock.png"];
            type = kClock;
            powerupSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // dietary plan
        case 3:
            powerupTexture = [SKTexture textureWithImageNamed:@"scale.png"];
            type = kDietaryPlan;
            powerupSize = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
            break;
            
        // bottled water
        case 4:
            powerupTexture = [SKTexture textureWithImageNamed:@"waterbottle.png"];
            type = kBottledWater;
            powerupSize = CGSizeMake(RECT_OBJECT_SIZE_WIDTH, RECT_OBJECT_SIZE_HEIGHT);
            break;
    }
    
    // spawn the powerup
    Powerup* newPowerup = [[Powerup alloc] initWithTexture:powerupTexture andSpeed:kFast andPowerupType:type];
    newPowerup.size = powerupSize;
    
    // random starting x-position
    u_short startingXPos = arc4random_uniform(self.frame.size.width - 2*newPowerup.size.width) + newPowerup.size.width;
    
    // properties for the new falling powerup
    
    newPowerup.position = CGPointMake(startingXPos, self.frame.size.height - HUD_HEIGHT - newPowerup.size.height/2);
    
    newPowerup.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newPowerup.size];
    newPowerup.physicsBody.friction = 0.0f;
    
    
    // air friction based on the speed of the powerup
    if(newPowerup.speed == kNormal)
        newPowerup.physicsBody.linearDamping = 0.3f * _speedMultiplier; // air friction
    
    // kFast
    else if(newPowerup.speed == kFast)
        newPowerup.physicsBody.linearDamping = 0.1f * _speedMultiplier;
    
    // kSlow
    else
        newPowerup.physicsBody.linearDamping = 0.5f * _speedMultiplier;
    
    
    newPowerup.physicsBody.allowsRotation = false;
    newPowerup.physicsBody.usesPreciseCollisionDetection = false;
    newPowerup.physicsBody.categoryBitMask = ColliderTypePowerUp;
    newPowerup.physicsBody.collisionBitMask = ColliderTypeFondue;
    newPowerup.physicsBody.contactTestBitMask = ColliderTypeFondue;
    
    [self addChild:newPowerup];
}

/*
 * Checks if the minimum time required to spawn another object has passed
 * If so, randomly decides whether or not to spawn a new object, and returns the decision.
 * If YES, the spawn timer for objects is reset.
 * If max time required to spawn another object has passed, automatically decides YES
 */
-(BOOL)checkObjectSpawn
{
    // calculate delta time since last object spawn
    double currTime = (double)CFAbsoluteTimeGetCurrent();
    float dt = currTime - _lastObjectSpawnTime;
    
    // if past max time required for spawn, automatically choose to spawn
    if(dt >= MAX_OBJECTSPAWN_TIME)
    {
        // reset the spawn time
        _lastObjectSpawnTime = currTime;
        
        // choose to spawn
        return true;
    }
    
    // if below max time required for spawn, automatically choose to not spawn
    else if(dt < MIN_OBJECTSPAWN_TIME)
        return false;
    
    // dt is between MIN_SPAWN and MAX_SPAWN
    else
    {
        // randomly decide whether or not to spawn
        int random = arc4random_uniform(100);
        
        
        // >= 25 spawns
        if(random > 25)
        {
            // reset the spawn time
            _lastObjectSpawnTime = currTime;
            
            // choose to spawn
            return true;
        }
        
        // do not spawn
        else
            return false;
    }
}

/*
 * Checks if the minimum time required to spawn another powerup has passed
 * If so, randomly decides whether or not to spawn a new object, and returns the decision.
 * If YES, the spawn timer for power-ups is reset
 */
-(BOOL)checkPowerupSpawn
{
    // calculate delta time since last powerup spawn
    double currTime = (double)CFAbsoluteTimeGetCurrent();
    float dt = currTime - _lastPowerupSpawnTime;
    
    // if past max time required for spawn, automatically choose to spawn
    if(dt >= MAX_POWERUPSPAWN_TIME)
    {
        // reset the spawn time
        _lastPowerupSpawnTime = currTime;
        
        // choose to spawn
        return true;
    }
    
    // if below min time required for spawn, automatically choose not to spawn
    else if(dt < MIN_POWERUPSPAWN_TIME)
        return false;
    
    // dt is between MIN_SPAWN and MAX_SPAWN
    else
    {
        // randomly decide whether or not to spawn
        u_short random = arc4random_uniform(100);
        
        // >= 80 spawns
        if(random > 80)
        {
            // reset the spawn time
            _lastPowerupSpawnTime = currTime;
            
            // choose to spawn
            return true;
        }
        
        // else choose not to spawn
        else
            return false;
    }
}

/*
 * Chooses an object to spawn and returns it
 */
-(u_short)chooseObject
{
    u_short random = arc4random_uniform(100);
    
    // choose between food or non-food item
    
    // food item
    if(random < 50)
    {
        // new random value for type of food item
        random = arc4random_uniform(100);
        
        /*
         * choose a food item to spawn based on the random value, from the list:
         * 0) banana
         * 1) cookie
         * 2) strawberry
         * 3) icecream
         * 4) pretzel
         */
        
        if(random < 10)
            return 0;
        
        if(random < 30)
            return 1;
        
        if(random < 60)
            return 2;
        
        if(random < 80)
            return 3;
        
        else
            return 4;
    }
    
    // non-food item
    else
    {
        // new random value for type of non-food item
        random = arc4random_uniform(100);
        
        /*
         * Choose a non-food item to spawn based on the random value, from the list:
         * 5) cat
         * 6) umbrella
         * 7) cup
         * 8) frying pan
         * 9) spoon
         */
        
        if(random < 10)
            return 5;
        
        else if(random < 30)
            return 6;
        
        else if(random < 60)
            return 7;
        
        else if(random < 80)
            return 8;
        
        else
            return 9;
    }
}

/*
 * Chooses a powerup to spawn and returns it
 */
-(u_short)choosePowerup
{
    u_short random = arc4random_uniform(100);
    
    /*
     * choose a powerup based on the random value, from the list:
     *
     * 0) caramel (10%)
     * 1) chocolate bar (40%)
     * 2) clock (20%)
     * 3) dietary plan (15%)
     * 4) bottled water (15%)
     */
    
    // caramel
    if(random < 10)
        return 0;
    
    // chocolate bar
    else if(random < 50)
        return 1;
    
    // clock
    else if(random < 70)
        return 2;
    
    // dietary plan
    else if(random < 85)
    {
        // only spawn a new dietary plan powerup if the fondue multiplier is not 1
        if(_fondueMultiplier != 1 && currentState == kChocolateState)
            return 3;
        
        // otherwise spawn a caramel
        else
            return 0;
    }
    
    // bottled water
    else
    {
        // only spawn water if we are in chocolate state
        if(currentState == kChocolateState)
            return 4;
        
        // otherwise spawn a caramel
        else
            return 0;
    }
}

#pragma mark -
#pragma mark Collision


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // if first body is of type fondue
    if ((firstBody.categoryBitMask & ColliderTypeFondue) != 0)
    {
        // get fondue node from matching physicsBody
        SKNode *fondue = firstBody.node;
        
        // get collision object node from matching physics body
        FallingObject* collisionObject = (FallingObject*)secondBody.node;
        
        /* Type of second physics body */
        
        // if fondue
        if((secondBody.categoryBitMask & ColliderTypeFondue) != 0)
        {
            // do nothing
        }
        
        // hitting non-fondue
        else
        {
            // food
            if((secondBody.categoryBitMask & ColliderTypeFood) != 0)
            {
                // chocolate state
                if(currentState == kChocolateState)
                {
                    // +score
                    _score += _scoreMultiplier * collisionObject.value;
                    
                    // prevent score from going above the MAX_SCORE
                    if(_score > MAX_SCORE)
                        _score = MAX_SCORE;
                }
                
                // water state
                else if(currentState == kWaterState)
                {
                    // -score
                    _score -= /*_scoreMultiplier **/ collisionObject.value;
                    
                    // prevent score from falling below 0
                    if(_score < 0)
                        _score = 0;
                }
                
                [_soundManager playSoundEffect:kSplatSound];
            }
            
            // non-food
            else if((secondBody.categoryBitMask & ColliderTypeNonFood) != 0)
            {
                // chocolate state
                if(currentState == kChocolateState)
                {
                    // -score
                    _score -= /*_scoreMultiplier **/ collisionObject.value;
                    
                    // prevent score from falling below 0
                    if(_score < 0)
                        _score = 0;
                }
                
                // water state
                else if(currentState == kWaterState)
                {
                    // +score
                    _score += _scoreMultiplier * collisionObject.value;
                    
                    // prevent score from going above the MAX_SCORE
                    if(_score > MAX_SCORE)
                        _score = MAX_SCORE;
                }
                 [_soundManager playSoundEffect:kSplatSound];
            }
            
            // power-up
            else
            {
                // handle powerup resolution
                [self handlePowerupResolution:secondBody];
                [_soundManager playSoundEffect:kPowerupSound];
            }
            
            // create splat at location. Type of splat is based on current state
            [self createSplatAtX:firstBody.node.position.x andY:firstBody.node.position.y];
            
            // remove fondue and colliding object
            [fondue runAction:[SKAction removeFromParent]];
            [collisionObject runAction:[SKAction removeFromParent]];
        }
    }
}

/*
 * Creates a splat at the target location
 * and removes it quickly afterwards.
 * The type of splat created is based on the current state
 */
-(void)createSplatAtX:(int)x andY:(int)y
{
    if(currentState != kDoneState)
    {
        SKSpriteNode* newSplat;
    
        // chocolate splat during chocolate state
        if(currentState == kChocolateState)
            newSplat = [[SKSpriteNode alloc]initWithImageNamed:@"splat.png"];
    
        // water splat during water state
        else if(currentState == kWaterState)
            newSplat = [[SKSpriteNode alloc]initWithImageNamed:@"watersplat.png"];
    
        newSplat.position = CGPointMake(x, y);
        newSplat.size = CGSizeMake(SQUARE_OBJECT_SIZE, SQUARE_OBJECT_SIZE);
    
        [self addChild:newSplat];
    
        [newSplat runAction:splat];
    }
}

/*
 * Activates powerup effects based on the powerup that was collided with
 */
-(void)handlePowerupResolution:(SKPhysicsBody*)powerupBody
{
    // reference the powerup
    Powerup* currPowerup = (Powerup*)powerupBody.node;
    
    // run the action corresponding to the powerup
    // action is run on the scene since the powerups will be removed after the resolution is over
    switch (currPowerup.type)
    {
        case kChocolateBar:
            [self.scene runAction:pu_chocolateBar];
            break;
            
        case kCaramel:
            [self.scene runAction:pu_caramel];
            break;
            
        case kBottledWater:
                [self.scene runAction:pu_bottledWater];
            break;
            
        case kDietaryPlan:
                [self.scene runAction:pu_dietaryPlan];
            break;
            
        case kClock:
            [self.scene runAction: pu_clock];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Garbage Collection


- (void)didSimulatePhysics
{
    // Remove flungFondue if it exits the screen on the sides or the bottom
    [self enumerateChildNodesWithName:@"flungFondue" usingBlock:^(SKNode *node, BOOL *stop)
    {
        if(node.position.y < 0) [node removeFromParent];
        if(node.position.x < 0) [node removeFromParent];
        if(node.position.x > self.frame.size.width) [node removeFromParent];
    }];
    // Remove fallingObjects if it exits the screen on the sides or the bottom
    [self enumerateChildNodesWithName:@"fallingObject" usingBlock:^(SKNode *node, BOOL *stop)
    {
        if(node.position.y < 0) [node removeFromParent];
        if(node.position.x < 0) [node removeFromParent];
        if(node.position.x > self.frame.size.width) [node removeFromParent];
    }];
}

@end
