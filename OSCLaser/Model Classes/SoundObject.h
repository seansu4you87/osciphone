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
#import "NoteObject.h"
#import "BlitSaw.h"
#import "BlitSquare.h"
#import "ADSR.h"
#import "OnePole.h"
#import "Modulate.h"


using namespace stk;

enum {
	SINE = 0, SAW = 1, SQUARE = 2
};

typedef struct {
	float min;
	float max;
	float cur;
	float target;
} SoundParams;

@interface SoundObject : NSObject {
	
	int carOsc;
	int modOsc;
	int scaleType;
	SineWave *sineCarrier;
	BlitSaw *sawCarrier;
	BlitSquare *squareCarrier;
	SineWave *sineModulator;
	BlitSaw *sawModulator;
	BlitSquare *squareModulator;
	OnePole *lpf;
	OnePole *hpf;
	Modulate *vibrato;
	ADSR *adsr;
	float gain;
	SoundParams scaledGain;
	SoundParams carFreq;
	SoundParams pan;
	SoundParams modFreq;
	SoundParams modIndex;
	SoundParams lpPole;
	SoundParams hpPole;
	SoundParams vibRate;
	SoundParams vibGain;
	int numOctaves;
	int rootNote;
	BOOL quantizePitch;
	NSMutableArray * possibleNotes;
	BOOL seqencerOn;
	BOOL lastBeatWasOn;
}

@property(nonatomic, readonly) int carOsc, modOsc, numOctaves, rootNote, scaleType;
@property(nonatomic, readonly) float gain;
@property(nonatomic, readonly) BOOL quantizePitch, seqencerOn;
@property(nonatomic, readonly) SoundParams carFreq, pan, modFreq, modIndex, lpPole, hpPole, vibRate, vibGain;
@property(nonatomic, readonly) NSMutableArray * possibleNotes;

- (void) initPossibleNotes;
- (void) removePossibleNote:(int)note;
- (void) addPossibleNote:(int)note;
- (BOOL) containsNote:(int)note;
- (void) setNotes:(NSArray*)newNotes;
- (void) setNumOctaves:(int)newNumOctaves;
- (void) setRootNote:(int)newRootNote;
- (float) getQuantizedPitchAt:(float)yLoc;
- (BOOL) scaleContainsTop;


- (void) setForPointOne:(CGPoint)scaledPoint;
- (void) setForPointTwo:(CGPoint)scaledPoint;
- (void) setForPointThree:(CGPoint)scaledPoint;
- (void) setForPointFour:(CGPoint)scaledPoint;
- (void) synthesize:(Float32 *)buffer of:(UInt32)numFrames that:(BOOL)isOn at:(int)t andAlso:(BOOL)seqencerIsActive;

- (void) setQuantizePitch:(BOOL)newVal;
- (void) setScaleType:(int)newScaleType;
- (void) setCarOsc:(int)newOsc;
- (void) setModOsc:(int)newOsc;
- (void) setGain:(float)newGain;
- (void) setGainTargetScaledBy:(int)numObjects;
- (void) setCarFreqTarget:(float)yLoc;
- (void) setPanTarget:(float)xLoc;
- (void) setModFreqTarget:(float)yLoc;
- (void) setModIndexTarget:(float)xLoc;
- (void) setLPPoleTarget:(float)yLoc;
- (void) setHPPoleTarget:(float)xLoc;
- (void) setVibRateTarget:(float)yLoc;
- (void) setVibGainTarget:(float)xLoc;
- (void) updateScaledGain;
- (void) updateCarFreq;
- (void) updatePan;
- (void) updateModFreq;
- (void) updateModIndex;
- (void) updateLPPole;
- (void) updateHPPole;
- (void) updateVibRate;
- (void) updateVibGain;

- (int) numQuantizations;
- (void) turnOnSequencer;
- (void) turnOffSequencer;

@end
