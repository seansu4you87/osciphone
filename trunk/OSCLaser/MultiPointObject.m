//
//  MultiPointObject.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "MultiPointObject.h"
#import "ControlPoint.h"

@implementation MultiPointObject

- (id) init
{
	if(self = [super init])
	{
		controlPoints = [[NSMutableArray arrayWithCapacity:1] retain];
		controllingTouches = [[NSMutableSet setWithCapacity:1] retain];
	}
	
	return self;
}

- (BOOL) touchesAreRelevant:(NSSet*)touches
{
	return NO;
}

- (void) trackTouches:(NSSet*)touches
{
	for(ControlPoint * point in controlPoints)
	{
		if(![point beingTouched])
		{
			for(UITouch * touch in touches)
			{
				//check if relevant
				//if relevant, set controllingTouch and add to controllingTouches
			}
		}
	}
}

- (BOOL) stopTrackingTouches:(NSSet*)touches
{
	for(ControlPoint * point in controlPoints)
	{
		if([point beingTouched])
		{
			if([touches containsObject:point.controllingTouch])
			{
				point.controllingTouch = nil;
				[controllingTouches removeObject:point.controllingTouch];
			}
		}
	}
	
	return [controllingTouches count] == 0;
}

- (void) updateForTouches:(NSSet*)touches
{
}

- (NSMutableSet*) relevantTouches:(NSSet*)touches
{
	return [NSMutableSet setWithCapacity:0];
}

- (NSMutableSet*) trackedTouches
{
	NSMutableSet * relevant = [NSMutableSet setWithCapacity:0];
	
	for(ControlPoint * curPoint in controlPoints)
	{
		if([curPoint beingTouched])
		{
			[relevant addObject:curPoint];
		}
	}
	
	return relevant;
}

- (void) updateSelected
{
	[super updateSelected];
}

- (void) updateUnselected
{
	[super updateUnselected];
}

- (void) addControlPoint:(ControlPoint*)newPoint
{
	[controlPoints addObject:newPoint];	
}

- (NSString*) objectName
{
	return @"MObj";
}

- (void) step
{
	for(ControlPoint * curPoint in controlPoints)
	{
		[curPoint step];
	}
}

- (void) dealloc
{
	[controlPoints release];
	[controllingTouches release];
		
	[super dealloc];
}

@end
