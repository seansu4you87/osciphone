//
//  ControlPoint.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ControlPoint.h"

#define DEFAULT_RADIUS 30
#define VELOCITY_FACTOR 0.25

@implementation ControlPoint

@synthesize controllingTouch, position, radius;

- (id) init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) setVelocity:(CGPoint)newVelocity
{
	velocity = newVelocity;
}

- (void) setPosition:(CGPoint)newPosition
{
	prevPosition = position;
	position = newPosition;
}

- (void) setVelocityFromPointChange
{
	[self setVelocity:CGPointMake(position.x - prevPosition.x, position.y - prevPosition.y)];
}

- (id) initWithPosition:(CGPoint)thePosition andRadius:(float)theRadius
{
	if(self = [self init])
	{
		position = thePosition;
		radius = theRadius;
		velocity = CGPointZero;
	}
	
	return self;
}

+ (ControlPoint*) controlPointWithPosition:(CGPoint)thePosition
{
	return [ControlPoint controlPointWithPosition:thePosition andRadius:DEFAULT_RADIUS];
}

+ (ControlPoint*) controlPointWithPosition:(CGPoint)thePosition andRadius:(float)theRadius
{
	ControlPoint * result = [[ControlPoint alloc] initWithPosition:thePosition andRadius:theRadius];
	return [result autorelease];
}

- (void) step
{
	if(PHYSICS)
	{
		if(controllingTouch == nil)
		{
			[self setPosition:CGPointMake(position.x + VELOCITY_FACTOR*velocity.x, position.y + VELOCITY_FACTOR*velocity.y)];
		}
	}
}

- (BOOL) beingTouched
{
	return controllingTouch != nil;
}

- (void) dealloc
{
	[controllingTouch release];
	[super dealloc];
}

@end
