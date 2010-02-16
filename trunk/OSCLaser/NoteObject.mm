//
//  NoteObject.mm
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "NoteObject.h"


@implementation NoteObject

@synthesize note, isOn;

- (id) initWithScaleValue:(int)scaleValue
{
	if(self = [super init])
	{
		isOn = YES;
		note = scaleValue;
	}
	
	return self;
}

+ (int) convertToChromatic:(int)scaleValue fromType:(int)scaleType
{
	switch (scaleType) {
		case MAJOR:
			return [NoteObject majorToChromatic:scaleValue];
		case MINOR:
			return [NoteObject minorToChromatic:scaleValue];
		case PENTATONIC:
			return [NoteObject pentatonicToChromatic:scaleValue];
	}
	
	return scaleValue;
}

- (void) toggle
{
	isOn = !isOn;
}

+ (int) chromaticToPentatonic:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 2) return 1;
	else if(scaleValue == 4) return 2;
	else if(scaleValue == 7) return 3;
	else if(scaleValue == 9) return 4;
	else return 5;
}

+ (int) chromaticToMajor:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 2) return 1;
	else if(scaleValue == 4) return 2;
	else if(scaleValue == 5) return 3;
	else if(scaleValue == 7) return 4;
	else if(scaleValue == 9) return 5;
	else if(scaleValue == 11) return 6;
	else return 7;
}

+ (int) chromaticToMinor:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 2) return 1;
	else if(scaleValue == 3) return 2;
	else if(scaleValue == 5) return 3;
	else if(scaleValue == 7) return 4;
	else if(scaleValue == 8) return 5;
	else if(scaleValue == 10) return 6;
	else return 7;
}

+ (int) majorToChromatic:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 1) return 2;
	else if(scaleValue == 2) return 4;
	else if(scaleValue == 3) return 5;
	else if(scaleValue == 4) return 7;
	else if(scaleValue == 5) return 9;
	else if(scaleValue == 6) return 11;
	else return 12;
}


+ (int) minorToChromatic:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 1) return 2;
	else if(scaleValue == 2) return 3;
	else if(scaleValue == 3) return 5;
	else if(scaleValue == 4) return 7;
	else if(scaleValue == 5) return 8;
	else if(scaleValue == 6) return 10;
	else return 12;
}

+(int) pentatonicToChromatic:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 1) return 2;
	else if(scaleValue == 2) return 4;
	else if(scaleValue == 3) return 7;
	else if(scaleValue == 4) return 9;
	else return 12;
}

+ (int)numStepsForType:(int)scaleType
{
	switch (scaleType) {
		case MAJOR:
		case MINOR:
			return 8;
		case PENTATONIC:
			return 5;
		case CHROMATIC:
			return 12;
	}
	
	return 12;
}

+ (BOOL) array:(NSArray*)noteArray containsValue:(int)scaleValue
{
	for(NoteObject *curNote in noteArray)
	{
		if(curNote.note == scaleValue)
			return YES;
	}
	
	return NO;
}

@end
