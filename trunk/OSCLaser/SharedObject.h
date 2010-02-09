//
//  SharedObject.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SharedObject : NSObject {
	int objectID;
	BOOL selected;
	UIView * objectView;
}

@property(nonatomic, readonly) UIView * objectView;

+ (void) resetIDs;
+ (int) nextID;

- (NSString *) objectName;
- (void) updateAllValues;
- (BOOL) touchesAreRelevant:(NSSet*)touches;
- (void) trackTouches:(NSSet*)touches;
- (BOOL) stopTrackingTouches:(NSSet*)touches;
- (void) updateForTouches:(NSSet*)touches;
- (NSMutableSet*) relevantTouches:(NSSet*)touches;
- (NSMutableSet*) trackedTouches;
- (void) updateSelected;
- (void) updateUnselected;

- (void) step;

@property(nonatomic, readonly) int objectID;

@end
