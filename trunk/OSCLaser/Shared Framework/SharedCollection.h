//
//  SharedCollection.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sequencer.h"

@class SharedObject;

@interface SharedCollection : NSObject<SequencerDelegate> {
	NSMutableArray * sharedObjects;
}

@property(nonatomic, readonly) NSMutableArray * sharedObjects;

+ (SharedCollection*) sharedCollection;
+ (void) releaseCollection;

- (void) step;
- (NSArray*) objects;
- (void) addSharedObject:(SharedObject*)newObject;
- (void) removeSharedObject:(SharedObject*)deletedObject;
- (SharedObject*) objectWithID:(int)theID;

+ (NSString*) addressForObjectManip:(SharedObject*)theObject;
+ (NSString*) addressForObjectAdd:(SharedObject*)theObject;

@end
