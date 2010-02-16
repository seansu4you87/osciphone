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
	
	Sequencer *sequencer;
	int t;

}

- (void) startCallback;
+ (void) scaleGainOf:(Float32 *)buffer of:(int)numFrames containing:(int)numObjects;

@end
