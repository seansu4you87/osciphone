//
//  MultiPointObject.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "MultiPointObject.h"
#import "ControlPoint.h"
#import "SharedUtility.h"

@implementation MultiPointObject

#define VELOCITY_THRESHOLD 3.0
#define SELECTED_COLOR [UIColor yellowColor]

@synthesize parentView, currentColor, baseColor;

- (id) init
{
	if(self = [super init])
	{
		controlPoints = [[NSMutableArray arrayWithCapacity:1] retain];
	}
	
	return self;
}

- (id) initWithPoint:(CGPoint)initialStart
{
	if(self = [self init])
	{
		[self addControlPointAtPosition: initialStart];
	}
	
	return self;
}

- (NSArray*) getControlPoints
{
	return controlPoints;
}

- (BOOL) touchesAreRelevant:(NSSet*)touches
{
	return [self relevantTouches:touches] > 0;
}

- (BOOL) touch:(UITouch*)theTouch isRelevantToControlPoint:(ControlPoint*)theControlPoint
{
	if(parentView != nil)
	{
		CGPoint touchPoint = [theTouch locationInView:parentView];
		return [SharedUtility distanceFrom:touchPoint to:theControlPoint.position] <= theControlPoint.radius;
	}
	
	return NO;
}

- (void) trackTouches:(NSSet*)touches
{
	for(int i = [controlPoints count] - 1; i >=0; i--)
	{
		ControlPoint * point = [controlPoints objectAtIndex:i];
		if(![point beingTouched])
		{
			for(UITouch * touch in touches)
			{
				if(![controllingTouches containsObject:touch])
				{
					if([self touch:touch isRelevantToControlPoint:point])
					{
						point.controllingTouch = touch;
						[controllingTouches addObject:touch];
					}
				}
			}
		}
	}
}

- (BOOL) stopTrackingTouches:(NSSet*)touches
{
	for(ControlPoint * point in controlPoints)
	{
		if([point beingTouched])
		{
			if([touches containsObject:point.controllingTouch])
			{
				[controllingTouches removeObject:point.controllingTouch];
				if(PHYSICS)
				{
					CGPoint current = [point.controllingTouch locationInView:parentView];
					CGPoint prev = [point.controllingTouch previousLocationInView:parentView];
					CGPoint vel = CGPointMake(current.x - prev.x, current.y - prev.y);
					if([SharedUtility magnitudeOf:vel] < VELOCITY_THRESHOLD || ![point movedWithTouch])
					{
						vel = CGPointZero;
					}
					
					[point setVelocity:vel];
				}
				point.controllingTouch = nil;
				
			}
		}
	}
	
	return [controllingTouches count] == 0;
}

- (void) updateForTouches:(NSSet*)touches
{
	BOOL anyMoved = NO;
	if([touches intersectsSet:controllingTouches])
	{
		NSMutableSet * relevantOnes = [NSMutableSet setWithSet:touches];
		[relevantOnes intersectSet:controllingTouches];
		for(UITouch * movedTouch in relevantOnes)
		{
			for(ControlPoint * controlPoint in controlPoints)
			{
				if([controlPoint.controllingTouch isEqual:movedTouch])
				{
					CGPoint newPosition = [movedTouch locationInView:parentView];
					if(newPosition.x < controlPoint.radius)
						newPosition.x = controlPoint.radius;
					if(newPosition.x > parentView.frame.size.width - controlPoint.radius)
						newPosition.x = parentView.frame.size.width - controlPoint.radius;
					if(newPosition.y < controlPoint.radius)
							newPosition.y = controlPoint.radius;
					if(newPosition.y > parentView.frame.size.height - controlPoint.radius)
						newPosition.y = parentView.frame.size.height - controlPoint.radius;
					
					[controlPoint setPosition:newPosition];
					anyMoved = YES;
				}
			}
		
		}
	}
}

- (NSMutableSet*) relevantTouches:(NSSet*)touches
{
	NSMutableSet * result = [NSMutableSet setWithCapacity:1];
	
	for(UITouch * touch in touches)
	{
		if([controllingTouches containsObject:touch])
		{
			[result addObject:touch];
		}else{
			for(ControlPoint * point in controlPoints)
			{
				if(![point beingTouched])
				{
					if([self touch:touch isRelevantToControlPoint:point])
					{
						[result addObject:touch];
						continue;
					}
				}
			}
		}
	}
	
	return result;
}

- (NSMutableSet*) trackedTouches
{
	NSMutableSet * relevant = [NSMutableSet setWithCapacity:0];
	
	for(ControlPoint * curPoint in controlPoints)
	{
		if([curPoint beingTouched])
		{
			[relevant addObject:curPoint];
		}
	}
	
	return relevant;
}

- (void) updateSelected
{
	self.currentColor = self.baseColor;
	[super updateSelected];
}

- (void) updateUnselected
{
	self.currentColor = baseColor;
	[super updateUnselected];
}

- (void) addControlPointAtPosition:(CGPoint)newPosition
{
	[self addControlPoint:[ControlPoint controlPointWithPosition:newPosition]];
}

- (void) addControlPoint:(ControlPoint*)newPoint
{
	[controlPoints addObject:newPoint];
}

- (NSString*) objectName
{
	return @"MObj";
}

- (void) step
{
	for(ControlPoint * curPoint in controlPoints)
	{
		[curPoint stepInBounds:parentView.frame];
	}
}

- (BOOL) canAddControlPoint
{
	return [controllingTouches count] == [controlPoints count];
}

- (void) dealloc
{
	[controlPoints release];
	[currentColor release];
	[baseColor release];
		
	[super dealloc];
}

@end
