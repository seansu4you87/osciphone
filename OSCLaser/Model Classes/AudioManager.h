//
//  AudioManager.h
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/13/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sequencer.h"

#define MY_SRATE 16384
#define FRAMESIZE 512
#define NUMCHANNELS 2

@interface AudioManager : NSObject {
	
	BOOL mute;
	int t;
	int tempo;
	int beatTick;

}

@property(nonatomic, readonly) BOOL mute;
@property(nonatomic, readonly) int t, tempo, beatTick;

- (void) startCallback;
- (void) muteOn;
- (void) muteOff;
- (void) incBeatTick;

+ (AudioManager*) sharedManager;
+ (void) releaseShared;

- (int) getSamplesPerBeat;

@end
