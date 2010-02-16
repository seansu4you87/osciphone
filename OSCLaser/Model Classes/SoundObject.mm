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
		carOsc = [SharedUtility randBetween:0 andUpper:2];
		modOsc = [SharedUtility randBetween:0 andUpper:2];
		sineCarrier = new SineWave();
		sawCarrier = new BlitSaw(0);
		squareCarrier = new BlitSquare(0);
		sineModulator = new SineWave();
		sawModulator = new BlitSaw(0);
		squareModulator = new BlitSquare(0);
		adsr = new ADSR();
		gain = .9;
		
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
		
		// init
		
	}
	
	return self;
}

- (void) setCarOsc:(int)newOsc
{
	carOsc = newOsc;
}

- (void) setModOsc:(int)newOsc
{
	modOsc = newOsc;
}

- (void) setGain:(float)newGain
{
	gain = newGain;
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

- (void) setLPPoleTarget:(float)yLoc
{
	lpPole.target = lpPole.min + (lpPole.max - lpPole.min) * yLoc;
}

- (void) setHPPoleTarget:(float)xLoc
{
	hpPole.target = hpPole.min + (hpPole.max - hpPole.min) * xLoc;
}

- (void) setVibRateTarget:(float)yLoc
{
	vibRate.target = vibRate.max - (vibRate.max - vibRate.min) * yLoc;
}

- (void) setVibGainTarget:(float)xLoc
{
	vibGain.target = vibGain.min + (vibGain.max - vibGain.min) * xLoc;
}

- (void) updatePan
{
	pan.cur += SLEW * (pan.target - pan.cur);
}

- (void) updateCarFreq
{
	carFreq.cur += SLEW * (carFreq.target - carFreq.cur);

	// modulate carrier with modulator
	float freq = carFreq.cur;
	if(modIndex.cur > 0) 
	{
		if(modOsc == SAW) freq += modIndex.cur * sawModulator->tick();
		else if(modOsc == SQUARE) freq += modIndex.cur * squareModulator->tick();
		else freq += modIndex.cur * sineModulator->tick();
	}
	
	if(carOsc == SAW) sawCarrier->setFrequency( freq );
	else if(carOsc == SQUARE) squareCarrier->setFrequency( freq );
	else sineCarrier->setFrequency( freq );

}

- (void) updateModFreq
{
	modFreq.cur += SLEW * (modFreq.target - modFreq.cur);

	if(modOsc == SAW) sawModulator->setFrequency( modFreq.cur );
	else if(modOsc == SQUARE) squareModulator->setFrequency( modFreq.cur );
	else sineModulator->setFrequency( modFreq.cur );

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

- (int) numQuantizations
{
	return [possibleNotes count];
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
	for(int i = 0; i < numFrames; i++)
	{
		// update params
		[self updateParams];

		// current sample
		float curSamp;
		if(carOsc == SAW) curSamp = sawCarrier->tick() * gain;
		else if(carOsc == SQUARE) curSamp = squareCarrier->tick() * gain;
		else curSamp = sineCarrier->tick() * gain;
		// left channel contribution
		buffer[2*i] += .5 * (1 - pan.cur) * curSamp;
		// right channel contribution
		buffer[2*i+1] += .5 * (1 + pan.cur) * curSamp;

	}
}


@end
