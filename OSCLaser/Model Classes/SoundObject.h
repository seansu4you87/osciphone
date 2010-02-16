//
//  SoundObject.h
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/13/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Stk.h"
#import "SineWave.h"
#import "ADSR.h"
#import "OnePole.h"
#import "Modulate.h"


using namespace stk;

enum {
	SINE, SAW, SQUARE
};

typedef struct {
	float min;
	float max;
	float cur;
	float target;
} SoundParams;

@interface SoundObject : NSObject {
	
	Generator *carrier;
	Generator *modulator;
	OnePole *lpf;
	OnePole *hpf;
	Modulate *vibrato;
	ADSR *adsr;
	float gain;
	SoundParams carFreq;
	SoundParams pan;
	SoundParams modFreq;
	SoundParams modIndex;
	SoundParams lpPole;
	SoundParams hpPole;
	SoundParams vibRate;
	SoundParams vibGain;
	NSMutableArray * possibleNotes;
}

//- (void) stk::Generator::tick(){}

- (void) setForPointOne:(CGPoint)scaledPoint;
- (void) setForPointTwo:(CGPoint)scaledPoint;
- (void) setForPointThree:(CGPoint)scaledPoint;
- (void) setForPointFour:(CGPoint)scaledPoint;
- (void) synthesize:(Float32 *)buffer of:(UInt32)numFrames at:(int)t;

- (void) setCarOsc:(int)osc;
- (void) setModOsc:(int)osc;
- (void) setGain:(float)newGain;
- (void) setCarFreqTarget:(float)yLoc;
- (void) setPanTarget:(float)xLoc;
- (void) setModFreqTarget:(float)yLoc;
- (void) setModIndexTarget:(float)xLoc;
- (void) setLPPoleTarget:(float)yLoc;
- (void) setHPPoleTarget:(float)xLoc;
- (void) setVibRateTarget:(float)yLoc;
- (void) setVibGainTarget:(float)xLoc;
- (void) updateCarFreq;
- (void) updatePan;
- (void) updateModFreq;
- (void) updateModIndex;
- (void) updateLPPole;
- (void) updateHPPole;
- (void) updateVibRate;
- (void) updateVibGain;

- (int) numQuantizations;

@end
