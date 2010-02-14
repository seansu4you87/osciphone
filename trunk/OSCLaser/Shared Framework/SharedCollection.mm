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

static SharedCollection * shared;

@implementation SharedCollection

@synthesize sharedObjects;

+ (SharedCollection*) sharedCollection
{
	if(shared == nil)
	{
		shared = [[SharedCollection alloc] init];
	}
	
	return shared;
}

+ (void) releaseCollection
{
	if(shared != nil)
	{
		[shared release];
		shared = nil;
	}
}

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

- (void) step
{
	for(SharedObject * obj in sharedObjects)
	{
		[obj step];
		//[obj updateAllValues];
	}
	if([sharedObjects count] > 0)
	{
		SharedObject * obj = [sharedObjects objectAtIndex:0];
		[obj updateAllValues];
	}
}

- (void) sendAddMessageForObject:(SharedObject*)newObject
{
	NSString * addAddress = [NSString stringWithFormat:@"/%@/add", [newObject objectName]];
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort sendTo:(char*)[addAddress UTF8String] types:"i", newObject.objectID];
 }

- (void) sendDeleteMessageForObject:(SharedObject*)deletedObject
{
	NSString * deleteAddress = [NSString stringWithFormat:@"/%@/del", [deletedObject objectName]];
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort sendTo:(char*)[deleteAddress UTF8String] types:"i", deletedObject.objectID];
}
 
 - (void) addSharedObject:(SharedObject*)newObject
{
	[self sendAddMessageForObject:newObject];
	[sharedObjects addObject:newObject];
	[newObject updateAllValues];
}

- (void) removeSharedObject:(SharedObject*)deletedObject
{
	[self sendDeleteMessageForObject:deletedObject];
	[sharedObjects removeObjectAtIndex:[sharedObjects indexOfObject:deletedObject]];
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
	 return [NSString stringWithFormat:@"/%@/set/%d/", [theObject objectName], [theObject objectID]];
 }

@end
