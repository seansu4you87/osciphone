//
//  SoundObject.h
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/13/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stk.h"
#import "SineWave.h"
#import "ADSR.h"

using namespace stk;

typedef struct {
	float min;
	float max;
	float cur;
} SoundParams;

@interface SoundObject : NSObject {
	
	SineWave *carrier;
	SineWave *modulator;
	ADSR *adsr;
	float gain;
	SoundParams carFreq;
	SoundParams pan;
	SoundParams modFreq;
	SoundParams modIndex;

}

- (void) setForPointOne:(CGPoint)scaledPoint;
- (void) setForPointTwo:(CGPoint)scaledPoint;
- (void) setForPointThree:(CGPoint)scaledPoint;

- (void) setCarFreq:(float)yLoc;
- (void) setPan:(float)xLoc;
- (void) setModFreq:(float)yLoc;
- (void) setModIndex:(float)xLoc;
- (void) setGain:(float)newGain;

@end
