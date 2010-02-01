//
//  SharedCollection.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SharedCollection.h"
#import "SharedObject.h"
#import "OSCConfig.h"
#import "OSCPort.h"

@implementation SharedCollection

- (id) init
{
	if(self = [super init])
	{
		sharedObjects = [[NSMutableArray array] retain];
	}
	
	return self;
}

- (void) dealloc
{
	[sharedObjects release];
	[super dealloc];
}

- (void) sendAddMessageForObject:(SharedObject*)newObject
{
	NSString * addAddress = [NSString stringWithFormat:@"/%@/add", [newObject objectName]];
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort sendTo:[addAddress UTF8String] types:"i", newObject.objectID];
 }
 
 - (void) addSharedObject:(SharedObject*)newObject
{
	[sharedObjects addObject:newObject];
	[self sendAddMessageForObject:newObject];
	[newObject updateAllValues];
}

- (NSArray*) objects
{
	return [NSArray arrayWithArray:sharedObjects];
}

- (SharedObject*) objectWithID:(int)theID
{
	for(SharedObject * curObj in sharedObjects)
	{
		if(curObj.objectID == theID)
		{
			return curObj;
		}
	}
	
	return nil;
}
 
 + (NSString*) addressForObjectManip:(SharedObject*)theObject
 {
	 return [NSString stringWithFormat:@"/%@/manip", [theObject objectName]];
 }

@end
