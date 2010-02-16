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
	float drawnRadius;
	CGPoint prevPosition;
	CGPoint position;
	CGPoint velocity;
	CGPoint touchPosition;
	UITouch * controllingTouch;
}

@property(nonatomic, retain) UITouch * controllingTouch;
@property(nonatomic, assign) float drawnRadius;
@property(nonatomic, readonly) CGPoint touchPosition;
@property(nonatomic, readonly) CGPoint position;
@property(nonatomic, readonly) float radius;

- (void) stepInBounds:(CGRect)bounds;
- (BOOL) beingTouched;
- (BOOL) movedWithTouch;
- (void) setVelocity:(CGPoint)newVelocity;
- (void) setVelocityFromPointChange;
- (void) setPosition:(CGPoint)newPosition;

+ (ControlPoint*) controlPointWithPosition:(CGPoint)thePosition;
+ (ControlPoint*) controlPointWithPosition:(CGPoint)thePosition andRadius:(float)theRadius;

@end
