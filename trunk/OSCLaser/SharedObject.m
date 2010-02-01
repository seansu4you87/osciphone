//
//  SharedObject.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SharedObject.h"
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

+ (void) resetIDs
{
	currentID = 0;
}

+ (int) nextID
{
	currentID++;
	return currentID;
}

@end
