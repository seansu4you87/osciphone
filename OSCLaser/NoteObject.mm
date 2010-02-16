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

@end
