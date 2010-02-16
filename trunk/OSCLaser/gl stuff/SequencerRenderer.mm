//
//  SequencerRenderer.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SequencerRenderer.h"
#import "Sequencer.h"

@implementation SequencerRenderer

- (id) init
{
	if(self = [super init])
	{
		columnFaders = [[NSMutableArray arrayWithCapacity:16] retain];
	}
	
	return self;
}

- (id) initWithHeight:(float)theHeight andWidth:(float)theWidth
{
	if(self = [self init])
	{
		backingHeight = theHeight;
		backingWidth = theWidth;
	}
	
	return self;
}

- (void) renderSequencer:(Sequencer*)sequencer
{
}

- (void) dealloc
{
	[columnFaders release];
	[super dealloc];
}

@end
