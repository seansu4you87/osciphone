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

@synthesize objectID;

- (id) init
{
	if(self = [super init])
	{
		objectID = [SharedObject nextID];
	}
	
	return self;
}

- (NSString*) objectName
{
	return @"superObj";
}

- (void) updateAllValues
{
	//this needs to be overridden
}

- (void) updateForTouches:(NSSet*)touches
{
	//this needs to be overridden
}

- (void) trackTouches:(NSSet*)touches
{
	//override this
}

- (NSMutableSet*) relevantTouches:(NSSet*)touches
{
	return [NSMutableSet setWithCapacity:0];
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
	[objectView release];
	[super dealloc];
}

@end
