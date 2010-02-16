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
#import "MultiPointObject.h"

static Sequencer * theOne;

@implementation Sequencer

@synthesize delegate, beatsPerMeasure, numMeasures;

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

+ (NSString*) keyForMultiPointObject:(MultiPointObject*)mObj
{
	return [NSString stringWithFormat:@"%d", mObj.objectID];
}

- (NSArray*) currentObjects
{
	if(delegate != nil)
	{
		return [delegate objects];
	}
	
	return nil;
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
	[state setValue:[[[SequencerRow alloc] initWithLength:[self numBeats]] autorelease] forKey:[Sequencer keyForMultiPointObject:newObject]];
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
			if(![state valueForKey:[Sequencer keyForMultiPointObject:currentObject]])
			{
				[self addRowForObject:currentObject];
			}
		}
		/*
		NSArray * currentObjects = [state allKeys];
		for(id obj in currentObjects)
		{
			if(![objects containsObject:obj])
			{
				[self removeRowForObject:obj];
			}
		}
		 */
	}
}

- (int) numBeats
{
	return numMeasures*beatsPerMeasure;
}

- (BOOL) object:(id)obj isOnAtIndex:(int)beatIndex
{
	SequencerRow * row = [state valueForKey:[Sequencer keyForMultiPointObject:obj]];
	if(row != nil)
	{
		return [row onAtIndex:beatIndex];
	}
	
	return NO;
}

- (void) toggleBeat:(int)beatIndex forObject:(id)obj
{
	SequencerRow * row = [state valueForKey:[Sequencer keyForMultiPointObject:obj]];
	if(row != nil)
	{
		[row toggleAtIndex:beatIndex];
	}
}

- (void) toggleObject:(id)obj
{
	SequencerRow * row = [state valueForKey:[Sequencer keyForMultiPointObject:obj]];
	if(row != nil)
	{
		[row toggleRow];
	}
}

- (void) dealloc
 {
	 [state release];
	 [super dealloc];
 }
				 
@end
