//
//  SoundManager.m
//  ChocoFling
//
//  Created by Steven Shing on 2/2/14.
//  Copyright (c) 2014 Desu Ex Kitten. All rights reserved.
//

#import "SoundManager.h"
#import "ViewController.h"

@implementation SoundManager {
    BOOL _playSong;
    NSMutableDictionary *_soundDictionary;
    AVAudioPlayer *_bgPlayer;
}

static float const kSoundDefaultVolume = .6;

- (id)init
{
    self = [super init];
    if(self)
    {
        _soundDictionary = [NSMutableDictionary dictionary];
        [self createChannelMP3: kTitleBgm];
        [self createChannelMP3: kGameBgm];
        [self createChannelWav: kSplatSound];
        [self createChannelWav: kPowerupSound];
    }
    return self;
}


-(void)playSoundEffect:(NSString *)fileName
{
    AVAudioPlayer *player = _soundDictionary[fileName];
    player.currentTime = 0;
    [player play];
}

// Handles the background sound
-(void) playBackground: (int) gameState
{
    [self stopBackground];
    if(gameState == kGameStateTitle)
        _bgPlayer = _soundDictionary[kTitleBgm];
    else if(gameState == kGameStateGame)
        _bgPlayer = _soundDictionary[kGameBgm];
    _bgPlayer.currentTime = 0;
    _bgPlayer.volume = kSoundDefaultVolume;
    _bgPlayer.numberOfLoops = -1;
    [_bgPlayer play];
}

- (void) stopBackground
{
    if([_bgPlayer isPlaying])
        [_bgPlayer stop];
}

-(void) createChannelMP3:(NSString*)fileName
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    player.volume = kSoundDefaultVolume;
    [player prepareToPlay];
    
    _soundDictionary[fileName] = player;
}

-(void) createChannelWav:(NSString*)fileName
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    player.volume = kSoundDefaultVolume;
    [player prepareToPlay];
    
    _soundDictionary[fileName] = player;
}


@end
