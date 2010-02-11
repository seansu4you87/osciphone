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
#import "MultiPointObjectView.h"

@implementation MultiPointObject

@synthesize parentView;

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

- (void) setupView
{
	if(parentView != nil)
	{
		CGRect properFrame = parentView.frame;
		properFrame.origin.x = 0.0;
		properFrame.origin.y = 0.0;
		
		MultiPointObjectView * myView =  [[MultiPointObjectView alloc] initWithFrame:properFrame];
		myView.parentObject = self;
		objectView = myView;
	}
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
	for(ControlPoint * point in controlPoints)
	{
		if(![point beingTouched])
		{
			for(UITouch * touch in touches)
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

- (BOOL) stopTrackingTouches:(NSSet*)touches
{
	for(ControlPoint * point in controlPoints)
	{
		if([point beingTouched])
		{
			if([touches containsObject:point.controllingTouch])
			{
				[controllingTouches removeObject:point.controllingTouch];
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
					[controlPoint setPosition:[movedTouch locationInView:parentView]];
					anyMoved = YES;
				}
			}
		
		}
	}
	//this will go away when no longer using UIView stuff
	if(anyMoved)
	{
		[self.objectView setNeedsDisplay];
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
	[super updateSelected];
}

- (void) updateUnselected
{
	[super updateUnselected];
}

- (void) addControlPointAtPosition:(CGPoint)newPosition
{
	[self addControlPoint:[ControlPoint controlPointWithPosition:newPosition]];
}

- (void) addControlPoint:(ControlPoint*)newPoint
{
	[controlPoints addObject:newPoint];
	
	//this won't happen when we're drawing with GL
	[self.objectView setNeedsDisplay];
}

- (NSString*) objectName
{
	return @"MObj";
}

- (void) step
{
	for(ControlPoint * curPoint in controlPoints)
	{
		[curPoint step];
	}
}

- (BOOL) canAddControlPoint
{
	return [controllingTouches count] == [controlPoints count];
}

- (void) dealloc
{
	[controlPoints release];
		
	[super dealloc];
}

@end
