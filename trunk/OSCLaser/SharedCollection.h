//
//  SharedCollection.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SharedObject;

@interface SharedCollection : NSObject {
	NSMutableArray * sharedObjects;
}

- (NSArray*) objects;
- (void) addSharedObject:(SharedObject*)newObject;
- (void) removeSharedObject:(SharedObject*)deletedObject;
- (SharedObject*) objectWithID:(int)theID;
+ (NSString*) addressForObjectManip:(SharedObject*)theObject;

@end
