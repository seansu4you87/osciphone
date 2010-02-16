//
//  MultiPointObject.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedObject.h"
#import "SoundObject.h"

@class ControlPoint;

@interface MultiPointObject : SharedObject {
	BOOL laserAware;
	NSMutableArray * controlPoints;
	UIView * parentView;
	UIColor * baseColor;
	UIColor * currentColor;
	SoundObject * soundObject;
}


@property(nonatomic, assign) UIView * parentView;
@property(nonatomic, retain) UIColor * currentColor;
@property(nonatomic, retain) UIColor * baseColor;
@property(nonatomic, readonly) SoundObject * soundObject;

- (id) initWithView:(UIView*)theView points:(NSArray*)cgPoints;

- (NSArray*) getControlPoints;
- (void) addControlPointAtPosition:(CGPoint)newPosition;
- (void) addControlPoint:(ControlPoint*)newPoint;
- (BOOL) touch:(UITouch*)theTouch isRelevantToControlPoint:(ControlPoint*)theControlPoint;
- (BOOL) canAddControlPoint;
- (int) numControlPoints;
- (CGPoint) scaleXYPoint:(CGPoint)pointInViewCoords;
- (CGPoint) scaledPositionAtIndex:(int)index;

+ (id)copyWithZone:(NSZone *)zone;


@end
