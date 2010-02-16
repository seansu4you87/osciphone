//
//  NoteObject.mm
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "NoteObject.h"


@implementation NoteObject

@synthesize note;

- (id) initWithScaleValue:(int)scaleValue
{
	if(self = [super init])
	{
		note = scaleValue;
	}
	
	return self;
}

- (int) majorToChromatic:(int)scaleValue
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


- (int) minorToChromatic:(int)scaleValue
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

- (int) pentatonicToChromatic:(int)scaleValue
{
	if(scaleValue == 0) return 0;
	else if(scaleValue == 1) return 2;
	else if(scaleValue == 2) return 4;
	else if(scaleValue == 3) return 7;
	else if(scaleValue == 4) return 9;
	else return 12;
}

@end
