//
//  ControlPoint.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PHYSICS YES

@interface ControlPoint : NSObject {
	float radius;
	CGPoint prevPosition;
	CGPoint position;
	CGPoint velocity;
	UITouch * controllingTouch;
}

@property(nonatomic, retain) UITouch * controllingTouch;
@property(nonatomic, readonly) CGPoint position;
@property(nonatomic, readonly) float radius;

- (void) stepInBounds:(CGRect)bounds;
- (BOOL) beingTouched;
- (void) setVelocity:(CGPoint)newVelocity;
- (void) setVelocityFromPointChange;
- (void) setPosition:(CGPoint)newPosition;

+ (ControlPoint*) controlPointWithPosition:(CGPoint)thePosition;
+ (ControlPoint*) controlPointWithPosition:(CGPoint)thePosition andRadius:(float)theRadius;

@end
