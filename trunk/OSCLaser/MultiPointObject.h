//
//  MultiPointObject.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedObject.h"

@class ControlPoint;

@interface MultiPointObject : SharedObject {
	NSMutableArray * controlPoints;
	NSMutableSet * controllingTouches;
	UIView * parentView;
}

@property(nonatomic, assign) UIView * parentView;

- (void) addControlPoint:(ControlPoint*)newPoint;
- (BOOL) touch:(UITouch*)theTouch isRelevantToControlPoint:(ControlPoint*)theControlPoint;

@end
