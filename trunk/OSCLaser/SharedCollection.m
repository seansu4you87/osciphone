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

- (void) sendAddMessageForObject:(SharedObject*)newObject
{
	NSString * addAddress = [NSString stringWithFormat:@"/%@/add", [newObject objectName]];
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort sendTo:[addAddress UTF8String] types:"i", newObject.objectID];
 }
 
 - (void) addObject:(SharedObject*)newObject
{
	[sharedObjects addObject:newObject];
	[self sendAddMessageForObject:newObject];
	[newObject updateAllValues];
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
