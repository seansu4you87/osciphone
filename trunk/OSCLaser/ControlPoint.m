//
//  ControlPoint.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ControlPoint.h"
#import "SharedUtility.h"

#define DEFAULT_RADIUS 30
#define VELOCITY_FACTOR 0.15
#define MOVEMENT_THRESHOLD 5.0

@implementation ControlPoint

@synthesize controllingTouch, position, radius, touchPosition;;

- (id) init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) setControllingTouch:(UITouch *)theTouch
{
	[controllingTouch release];
	controllingTouch = [theTouch retain];
	if(controllingTouch != nil)
	{
		touchPosition = position;
	}
}

- (BOOL) movedWithTouch
{
	return [SharedUtility distanceFrom:position to:touchPosition] > MOVEMENT_THRESHOLD;
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

- (CGPoint) nextPoint
{
	return CGPointMake(position.x + VELOCITY_FACTOR*velocity.x, position.y + VELOCITY_FACTOR*velocity.y);
}

- (void) stepInBounds:(CGRect)bounds
{
	if(PHYSICS)
	{
		if(controllingTouch == nil)
		{
			CGPoint newPoint = [self nextPoint];
			if(newPoint.x - radius < 0 || newPoint.x + radius > bounds.size.width)
			{
				velocity.x = -1.0*velocity.x;
				newPoint = [self nextPoint];
			} else if(newPoint.y - radius < 0 || newPoint.y + radius > bounds.size.height)
			{
				velocity.y = -1.0*velocity.y;
				newPoint = [self nextPoint];
			}
			[self setPosition:newPoint];
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
