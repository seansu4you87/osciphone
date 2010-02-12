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
	UIView * parentView;
	UIColor * baseColor;
	UIColor * currentColor;
}


@property(nonatomic, assign) UIView * parentView;
@property(nonatomic, retain) UIColor * currentColor;
@property(nonatomic, retain) UIColor * baseColor;

- (id) initWithPoint:(CGPoint)initialStart;

- (NSArray*) getControlPoints;
- (void) addControlPointAtPosition:(CGPoint)newPosition;
- (void) addControlPoint:(ControlPoint*)newPoint;
- (BOOL) touch:(UITouch*)theTouch isRelevantToControlPoint:(ControlPoint*)theControlPoint;
- (BOOL) canAddControlPoint;

@end
