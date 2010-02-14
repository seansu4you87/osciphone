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
#import "MultiPointObject.h"

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

- (void) sendUpdateAllMultiPoint
{
	NSString * baseAddress = @"/MObj/setAll";
	NSMutableString * argString = [NSMutableString stringWithFormat:@""];
	for(int i = 0; i < [sharedObjects count]; i++)
	{
		MultiPointObject * curObject = [sharedObjects objectAtIndex:i];
		for(int j = 0; j < [curObject numControlPoints]; j++)
		{
			[argString appendString:@"ff"];
		}
	}
	
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort beginSendTo:(char*)[baseAddress UTF8String] types:(char*)[argString UTF8String]];
	
	for(int i = 0; i < [sharedObjects count]; i++)
	{
		MultiPointObject * curObject = [sharedObjects objectAtIndex:i];
		for(int j = 0; j < [curObject numControlPoints]; j++)
		{
			CGPoint scaledPoint = [curObject scaledPositionAtIndex:j];
			[thePort appendFloat:scaledPoint.x];
			[thePort appendFloat:scaledPoint.y];
		}
	}
	
	[thePort completeSend];
}

- (void) step
{
	for(SharedObject * obj in sharedObjects)
	{
		[obj step];
	}
	
	if([sharedObjects count] > 0)
	{
		[self sendUpdateAllMultiPoint];
	}
}

- (void) sendAddMessageForObject:(SharedObject*)newObject
{
	[newObject sendAddMessage];
 }

- (void) sendDeleteMessageForObject:(SharedObject*)deletedObject
{
	NSString * deleteAddress = [NSString stringWithFormat:@"/%@/del", [deletedObject objectName]];
	NSString * argString = [NSString stringWithFormat:@"i"];
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort sendTo:(char*)[deleteAddress UTF8String] types:(char*)[argString UTF8String], deletedObject.objectID];
}
 
 - (void) addSharedObject:(SharedObject*)newObject
{
	[self sendAddMessageForObject:newObject];
	[sharedObjects addObject:newObject];
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


+ (NSString*) addressForObjectAdd:(SharedObject*)theObject
{
	return [NSString stringWithFormat:@"/%@/add/", [theObject objectName]];
}
 
 + (NSString*) addressForObjectManip:(SharedObject*)theObject
 {
	 return [NSString stringWithFormat:@"/%@/set/%d/", [theObject objectName], [theObject objectID]];
 }

@end
