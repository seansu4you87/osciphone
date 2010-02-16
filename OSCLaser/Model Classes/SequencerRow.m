//
//  SequencerRow.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SequencerRow.h"
#import "Toggle.h"

@implementation SequencerRow

- (id) initWithLength:(int)length
{
	if(self = [super init])
	{
		rowOn = NO;
		toggles = [[NSMutableArray arrayWithCapacity:length] retain];
		for(int i = 0; i < length; i++)
		{
			[toggles addObject:[[[Toggle alloc] init] autorelease]];
		}
	}
	
	return self;
}

- (void) toggleRow
{
	rowOn = !rowOn;
}

- (BOOL) onAtIndex:(int)index
{
	Toggle * relevant = [toggles objectAtIndex:index];
	return [relevant isOn];
}

- (void) toggleAtIndex:(int)index
{
	Toggle * relevant = [toggles objectAtIndex:index];
	[relevant toggle];
}

- (void) dealloc
{
	[toggles release];
	
	[super dealloc];
}

@end
