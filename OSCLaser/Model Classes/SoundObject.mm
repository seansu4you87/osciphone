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

@implementation SoundObject


- (id) init
{
	if(self = [super init])
	{
		carrier = new SineWave();
		modulator = new SineWave();
		adsr = new ADSR();
		gain = .5;
		modIndex.min = [SharedUtility randfBetween:10 andUpper: 200];
		modIndex.max = [SharedUtility randfBetween:modIndex.min andUpper: 2000];
		modIndex.cur = 0;
		possibleNotes = [[NSMutableArray array] retain];
	}
	
	return self;
}

- (int) numQuantizations
{
	return 5;
	//return [possibleNotes count];
}

- (void) setPan:(float)xLoc
{
	pan.cur = xLoc;
}

- (void) setCarFreq:(float)yLoc
{
	carrier->setFrequency(yLoc);
}

- (void) setModFreq:(float)yLoc
{
	modulator->setFrequency(yLoc);
}

- (void) setModIndex:(float)xLoc
{
	modIndex.cur = xLoc;
}

- (void) setGain:(float)newGain
{
	gain = newGain;
}

- (void) setForPointOne:(CGPoint)scaledPoint
{
	[self setCarFreq: scaledPoint.y]; 
	[self setPan: scaledPoint.x]; 
}

- (void) setForPointTwo:(CGPoint)scaledPoint
{
	
}

- (void) setForPointThree:(CGPoint)scaledPoint
{
	
}

@end
