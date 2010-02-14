//
//  SharedObject.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SharedObject.h"
#import "OSCConfig.h"
#import "OSCPort.h"

static int currentID;

@implementation SharedObject

@synthesize objectID, controllingTouches, selected;

- (id) init
{
	if(self = [super init])
	{
		objectID = [SharedObject nextID];
		selected = NO;//this behavior will be handled by controller
		controllingTouches = [[NSMutableSet setWithCapacity:3] retain];
	}
	
	return self;
}

- (NSString*) objectName
{
	return @"superObj";
}

- (void) sendAddMessage
{
	//override this
}

- (void) sendUpdateMessage
{
	//override this
}

- (void) updateForTouches:(NSSet*)touches
{
	//this needs to be overridden
}

- (void) trackTouches:(NSSet*)touches
{
	//override this
}

- (void) step
{
	//override this
}

- (NSMutableSet*) relevantTouches:(NSSet*)touches
{
	return [NSMutableSet setWithCapacity:0];
}

- (NSMutableSet*) trackedTouches
{
	return [NSMutableSet setWithCapacity:0];
}

- (void) updateSelected
{
	selected = YES;
}

- (void) updateUnselected
{
	selected = NO;
}

- (BOOL) stopTrackingTouches:(NSSet*)touches
{
	//override this
	return YES;
}

+ (void) resetIDs
{
	currentID = 0;
}

+ (int) nextID
{
	currentID++;
	return currentID;
}

- (BOOL) touchesAreRelevant:(NSSet*)touches
{
	return NO;
}

- (void) dealloc
{
	[controllingTouches release];

	[super dealloc];
}

@end
