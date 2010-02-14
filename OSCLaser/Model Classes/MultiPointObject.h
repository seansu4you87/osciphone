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
	NSMutableArray * controlPoints;
	UIView * parentView;
	UIColor * baseColor;
	UIColor * currentColor;
	SoundObject * soundObject;
}


@property(nonatomic, assign) UIView * parentView;
@property(nonatomic, retain) UIColor * currentColor;
@property(nonatomic, retain) UIColor * baseColor;

- (id) initWithView:(UIView*)theView point:(CGPoint)initialStart;

- (NSArray*) getControlPoints;
- (void) addControlPointAtPosition:(CGPoint)newPosition;
- (void) addControlPoint:(ControlPoint*)newPoint;
- (BOOL) touch:(UITouch*)theTouch isRelevantToControlPoint:(ControlPoint*)theControlPoint;
- (BOOL) canAddControlPoint;
- (CGPoint) scaleXYPoint:(CGPoint)pointInViewCoords;
- (CGPoint) scaledPositionAtIndex:(int)index;

/*
 //how to access relevant shit
 - (void) readMultiPointObjects
 {
 SharedCollection * theCollection = [SharedCollection sharedCollection];
 NSMutableArray * multiPointObjects = theCollection.sharedObjects;
 for(int i = 0; i < [multiPointObjects count]; i++)
 {
 MultiPointObject * curObject = [multiPointObjects objectAtIndex:i];
 }
 
 for(MultiPointObject * curObject in multiPointObjects)
 {
 NSArray * controlPoints = [curObject getControlPoints];
 for(int i = 0; i < [controlPoints count]; i++)
 {
 ControlPoint * curPoint = [controlPoints objectAtIndex:i];
 CGPoint scaledPosition = [curObject scaleXYPoint:curPoint.position];
 //scaledPosition is an (x,y) point with x,y in [0,1]
 }
 }
 }
 */

@end
