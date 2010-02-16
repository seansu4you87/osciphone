//
//  SoundObject.mm
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/13/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SoundObject.h"
#import "SharedUtility.h"
#import "SineWave.h"
#import "ADSR.h"

#define SLEW .1

@implementation SoundObject


- (id) init
{
	if(self = [super init])
	{
		carrier = new SineWave();
		modulator = new SineWave();
		adsr = new ADSR();
		gain = .5;
		
		// init ball 1
		carFreq.min = [SharedUtility randfBetween:50 andUpper: 500];
		carFreq.max = [SharedUtility randfBetween:modIndex.min andUpper: 2500];
		carFreq.cur = 0;
		pan.min = -1;
		pan.max = 1;
		pan.cur = 0;

		// init ball 2
		modIndex.min = [SharedUtility randfBetween:10 andUpper: 200];
		modIndex.max = [SharedUtility randfBetween:modIndex.min andUpper: 2000];
		modIndex.cur = 0;
		modFreq.min = [SharedUtility randfBetween:10 andUpper: 200];
		modFreq.max = [SharedUtility randfBetween:modIndex.min andUpper: 1000];
		modFreq.cur = 0;
		
		
	}
	
	return self;
}

- (void) setPanTarget:(float)xLoc
{
	pan.target = (pan.max - pan.min) * xLoc + pan.min;
}

- (void) setCarFreqTarget:(float)yLoc
{
	carFreq.target = carFreq.max - (carFreq.max - carFreq.min) * yLoc;
}

- (void) setModFreqTarget:(float)yLoc
{
	modFreq.target = modFreq.max - (modFreq.max - modFreq.min) * yLoc;
}

- (void) setModIndexTarget:(float)xLoc
{
	modIndex.target = (modIndex.max - modIndex.min) * xLoc + modIndex.min;
}

- (void) setGain:(float)newGain
{
	gain = newGain;
}


- (void) updatePan
{
	pan.cur += SLEW * (pan.target - pan.cur);
}

- (void) updateCarFreq
{
	carFreq.cur += SLEW * (carFreq.target - carFreq.cur);
	// modulate carrier with modulator
	if(modIndex.cur > 0) carrier->setFrequency( carFreq.cur + modIndex.cur * modulator->tick() );
	// or not
	else carrier->setFrequency( carFreq.cur );
}

- (void) updateModFreq
{
	modFreq.cur += SLEW * (modFreq.target - modFreq.cur);
	modulator->setFrequency( modFreq.cur );
}

- (void) updateModIndex
{
	modIndex.cur += SLEW * (modIndex.target - modIndex.cur); 
}

- (void) setForPointOne:(CGPoint)scaledPoint
{
	[self setCarFreqTarget: scaledPoint.y]; 
	[self setPanTarget: scaledPoint.x]; 
}

- (void) setForPointTwo:(CGPoint)scaledPoint
{
	[self setModFreqTarget: scaledPoint.y]; 
	[self setModIndexTarget: scaledPoint.x]; 
}

- (void) setForPointThree:(CGPoint)scaledPoint
{
	
}

- (void) updateParams
{
	[self updatePan];
	[self updateCarFreq];
	[self updateModIndex];
	[self updateModFreq];
}

- (void) synthesize:(Float32 *)buffer of:(UInt32)numFrames
{
	//NSLog(@"freq: %f, pan: %f", carFreq.cur, pan.cur);
	for(int i = 0; i < numFrames; i++)
	{
		// update params
		[self updateParams];
		// current sample
		float curSamp = carrier->tick() * gain;
		// left channel contribution
		buffer[2*i] += .5 * (1 - pan.cur) * curSamp;
		// right channel contribution
		buffer[2*i+1] += .5 * (1 + pan.cur) * curSamp;
	}
}


@end
