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

#define SLEW .005

@implementation SoundObject


- (id) init
{
	if(self = [super init])
	{
		Stk::setSampleRate( 16384.0 );

		
		carOsc = [SharedUtility randBetween:0 andUpper:2];
		modOsc = 0;
		sineCarrier = new SineWave();
		sawCarrier = new BlitSaw(0);
		squareCarrier = new BlitSquare(0);
		sineModulator = new SineWave();
		sawModulator = new BlitSaw(0);
		squareModulator = new BlitSquare(0);
		lpf = new OnePole(0);
		hpf = new OnePole(0);
		vibrato = new Modulate();
		adsr = new ADSR();
		quantizePitch = YES;
		gain = .8;
		scaledGain.cur = 0;
		
		
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
		
		// init ball 3
		lpPole.min = .1;
		lpPole.max = .99999;
		lpPole.cur = 0;
		hpPole.min = -.1;
		hpPole.max = -.4;
		hpPole.cur = 0;
		
		// init ball 4
		vibRate.min = [SharedUtility randfBetween:4 andUpper: 6];
		vibRate.max = [SharedUtility randfBetween:10 andUpper: 15];
		vibRate.cur = 0;
		vibGain.min = [SharedUtility randfBetween:10 andUpper: 20];
		vibGain.max = [SharedUtility randfBetween:30 andUpper: 40];
		vibGain.cur = 0;
		
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

- (void) setGainTargetScaledBy:(int)numObjects
{
	scaledGain.target = gain/numObjects;
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

- (void) updateScaledGain
{
	scaledGain.cur += SLEW * (scaledGain.target - scaledGain.cur);
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
	// add vibrato
	if(vibGain.cur > 0) freq += vibrato->tick();
	
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

- (void) updateLPPole
{
	lpPole.cur += SLEW * (lpPole.target - lpPole.cur); 
	lpf->setPole(lpPole.cur);
}

- (void) updateHPPole
{
	hpPole.cur += SLEW * (hpPole.target - hpPole.cur); 
	hpf->setPole(hpPole.cur);
}

- (void) updateVibRate
{
	vibRate.cur += SLEW * (vibRate.target - vibRate.cur); 
	vibrato->setVibratoRate(vibRate.cur);
}

- (void) updateVibGain
{
	vibGain.cur += SLEW * (vibGain.target - vibGain.cur); 
	vibrato->setVibratoGain(vibGain.cur);
	vibrato->setRandomGain(vibGain.cur);
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
	[self setLPPoleTarget: scaledPoint.y];
	[self setHPPoleTarget: scaledPoint.x];
}

- (void) setForPointFour:(CGPoint)scaledPoint
{
	[self setVibRateTarget: scaledPoint.y];
	[self setVibGainTarget: scaledPoint.x];
}

- (int) numQuantizations
{
	return [possibleNotes count];
}

- (void) updateParams
{
	if(scaledGain.cur != scaledGain.target) [self updateScaledGain];
	if(pan.cur != pan.target) [self updatePan];
	if(carFreq.cur != carFreq.target) [self updateCarFreq];
	if(modIndex.cur != modIndex.target) [self updateModIndex];
	if(modFreq.cur != modFreq.target) [self updateModFreq];
	if(lpPole.cur != lpPole.target) [self updateLPPole];
	if(hpPole.cur != hpPole.target) [self updateHPPole];
	if(vibRate.cur != vibRate.target) [self updateVibRate];
	if(vibGain.cur != vibGain.target) [self updateVibGain];
}

- (void) synthesize:(Float32 *)buffer of:(UInt32)numFrames
{
	for(int i = 0; i < numFrames; i++)
	{
		// update params
		[self updateParams];

		// current sample
		float curSamp;
		// filter
		if(lpPole.cur > 0 && hpPole.cur < 0)
		{
			if(carOsc == SAW) curSamp = lpf->tick( hpf->tick( sawCarrier->tick() ) );
			else if(carOsc == SQUARE) curSamp = lpf->tick( hpf->tick( squareCarrier->tick() ) );
			else curSamp = lpf->tick( hpf->tick( sineCarrier->tick() ) );
		}
		// or not
		else
		{
			if(carOsc == SAW) curSamp = sawCarrier->tick();
			else if(carOsc == SQUARE) curSamp = squareCarrier->tick();
			else curSamp = sineCarrier->tick();
		}
		// apply gain
		curSamp *= scaledGain.cur;
		// left channel contribution
		buffer[2*i] += .5 * (1 - pan.cur) * curSamp;
		// right channel contribution
		buffer[2*i+1] += .5 * (1 + pan.cur) * curSamp;

	}
}


@end
