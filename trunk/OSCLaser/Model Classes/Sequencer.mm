//
//  Sequencer.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "Sequencer.h"
#import "SequencerRow.h"
#import "SharedCollection.h"

static Sequencer * theOne;

@implementation Sequencer

@synthesize delegate;

+ (Sequencer*)sharedSequencer
{
	if(theOne == nil)
	{
		theOne = [[Sequencer alloc] initWithDelegate:[SharedCollection sharedCollection] measures:4 BPM:4];
	}
	
	return theOne;
}

+ (void) releaseShared
{
	[theOne release];
}

- (id) initWithDelegate:(id<SequencerDelegate>)theDelegate measures:(int)nMeasures BPM:(int)bpm
{
	if(self = [super init])
	{
		self.delegate = theDelegate;
		numMeasures = nMeasures;
		beatsPerMeasure = bpm;
		state = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	}
	
	return self;
}

- (void) addRowForObject:(id)newObject
{
	[state setObject:[[[SequencerRow alloc] initWithLength:[self numBeats]] autorelease] forKey:newObject];
}

- (void) removeRowForObject:(id)deletedObject
{
	[state removeObjectForKey:deletedObject];
}

- (void) refresh
{
	if(delegate != nil)
	{
		NSArray * objects = [delegate objects];
		for(int i = 0; i < [objects count]; i++)
		{
			id currentObject = [objects objectAtIndex:i];
			if(![state objectForKey:currentObject])
			{
				[self addRowForObject:currentObject];
			}
		}
		NSArray * currentObjects = [state allKeys];
		for(id obj in currentObjects)
		{
			if(![objects containsObject:obj])
			{
				[self removeRowForObject:obj];
			}
		}
	}
}

- (int) numBeats
{
	return numMeasures*beatsPerMeasure;
}

- (void) dealloc
 {
	 [state release];
	 [super dealloc];
 }
				 
@end
