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
#import "NoteObject.h"
#import "AudioManager.h"
#import "Sequencer.h"

#define SLEW .01
#define FRAMES_PER_UPDATE 50

@implementation SoundObject

@synthesize carOsc, modOsc, numOctaves, rootNote, gain, quantizePitch, seqencerOn, possibleNotes;
@synthesize carFreq, pan, modFreq, modIndex, lpPole, hpPole, vibRate, vibGain, scaleType;

- (id) init
{
	if(self = [super init])
	{
		Stk::setSampleRate( MY_SRATE * 1.0 );

		
		carOsc = 0;
		modOsc = 0; //[SharedUtility randBetween:0 andUpper:2];
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
		numOctaves = [SharedUtility randBetween:1 andUpper:3];
		rootNote = 42;
		[self initPossibleNotes];
		seqencerOn = YES;
		lastBeatWasOn = NO;
		gain = .8;
		scaledGain.cur = 0;
		
		//init ADSR
		adsr = new ADSR();
		adsr->setAttackTime( [SharedUtility randfBetween:.0001 andUpper: .01] );
		adsr->setDecayTime( [SharedUtility randfBetween:.0001 andUpper: .05] );
		adsr->setAttackTime( [SharedUtility randfBetween:.3 andUpper: .6] );
		adsr->setAttackTime( [SharedUtility randfBetween:.001 andUpper: .1] );
		adsr->keyOff();
		
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

- (void) initPossibleNotes
{
	possibleNotes = [[NSMutableArray arrayWithCapacity:6] retain];
	[possibleNotes addObject:[[[NoteObject alloc] initWithScaleValue:0] autorelease]];
	[possibleNotes addObject:[[[NoteObject alloc] initWithScaleValue:2] autorelease]];
	[possibleNotes addObject:[[[NoteObject alloc] initWithScaleValue:4] autorelease]];
	[possibleNotes addObject:[[[NoteObject alloc] initWithScaleValue:7] autorelease]];
	[possibleNotes addObject:[[[NoteObject alloc] initWithScaleValue:9] autorelease]];
	[possibleNotes addObject:[[[NoteObject alloc] initWithScaleValue:12] autorelease]];
}

- (void) removePossibleNote:(int)note
{
	for(NoteObject *curNote in possibleNotes)
	{
		if(curNote.note == note) [possibleNotes removeObject:curNote];
	}
}

- (void) addPossibleNote:(int)note
{
	for(int i = 0; i < [possibleNotes count]; i++)
	{
		NoteObject *curNote = [possibleNotes objectAtIndex:i];
		if(curNote.note > note) 
			[possibleNotes insertObject:[[[NoteObject alloc] initWithScaleValue:note] autorelease] atIndex:i];
	}
}

- (void) setNumOctaves:(int)newNumOctaves
{
	numOctaves = newNumOctaves;
}

- (void) setRootNote:(int)newRootNote
{
	rootNote = newRootNote;
}

- (BOOL) containsNote:(int)note
{
	return [NoteObject array:possibleNotes containsValue:note];
}

- (float) getQuantizedPitchAt:(float)yLoc
{
	int numNotes = [self numQuantizations];
	float stepSize = 1.0 / numNotes;
	int step = floor( (1- yLoc) / stepSize);
	
	// if it's at the top note, done
	if(step == numNotes && [self scaleContainsTop])
	{
		int midi = rootNote + 12 * numOctaves;
		return [SharedUtility mtof:midi];
	}
	
	int numScaleTones = [possibleNotes count];
	if([self scaleContainsTop]) numScaleTones--;
	int octave = floor(1.0 * step / numScaleTones);
	int index = step % numScaleTones;
	NoteObject *noteObject = [possibleNotes objectAtIndex:index];
	int scaleValue = noteObject.note;
	int midi = rootNote + 12 * octave + scaleValue;
	return [SharedUtility mtof:midi];
}

- (void) setQuantizePitch:(BOOL)newVal
{
	quantizePitch = newVal;
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
	if(quantizePitch) carFreq.target = [self getQuantizedPitchAt:yLoc];
	else carFreq.target = carFreq.max - (carFreq.max - carFreq.min) * yLoc;
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

- (BOOL) scaleContainsTop
{
	NoteObject *noteObject = [possibleNotes objectAtIndex: [possibleNotes count] - 1];
	return noteObject.note == 12;
}

- (int) numQuantizations
{
	if(!quantizePitch)
	{
		return 0;
	}
	
	int num = [possibleNotes count] * numOctaves;
	if([self scaleContainsTop]) num -= numOctaves - 1;
	return num;
}

- (void) turnOnSequencer
{
	seqencerOn = YES;
}

- (void) turnOffSequencer
{
	seqencerOn = NO;
}

- (void) setScaleType:(int)newScaleType
{
	scaleType = newScaleType;
}

- (void) setNotes:(NSArray *)newNotes
{
	[possibleNotes removeAllObjects];
	[possibleNotes addObjectsFromArray:newNotes];
}

- (void) updateParams
{
	if(scaledGain.cur != scaledGain.target) [self updateScaledGain];
	if(pan.cur != pan.target) [self updatePan];
	if(modIndex.cur != modIndex.target) [self updateModIndex];
	if(modFreq.cur != modFreq.target) [self updateModFreq];
	if(lpPole.cur != lpPole.target) [self updateLPPole];
	if(hpPole.cur != hpPole.target) [self updateHPPole];
	if(vibRate.cur != vibRate.target) [self updateVibRate];
	if(vibGain.cur != vibGain.target) [self updateVibGain];
}

- (void) synthesize:(Float32 *)buffer of:(UInt32)numFrames that:(BOOL)isOn at:(int)t 
{
	
	int samplesPerBeat = [[AudioManager sharedManager] getSamplesPerBeat];
	
	for(int i = 0; i < numFrames; i++)
	{
		int adsrState = adsr->getState();
		//NSLog(@"state: %d", adsrState);
		if(adsr->getState() != ADSR::DONE) 
		{
			if(t % samplesPerBeat == 0)
			{
				if(isOn) 
				{
					adsr->keyOn();
					//NSLog(@"keyOn! spb: %d", samplesPerBeat);
				}
				else 
				{
					adsr->keyOn();
					//NSLog(@"keyOff!");
				}
			}
				
			if(i%FRAMES_PER_UPDATE == 0)
			{
				// update params
				[self updateParams];
			}
			
			// always update carrier
			if(carFreq.cur != carFreq.target) [self updateCarFreq];
			
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
			// apply ADSR
			curSamp *= adsr->tick();
			// left channel contribution
			buffer[2*i] += .5 * (1 - pan.cur) * curSamp;
			// right channel contribution
			buffer[2*i+1] += .5 * (1 + pan.cur) * curSamp;
		}
	}
}


@end
