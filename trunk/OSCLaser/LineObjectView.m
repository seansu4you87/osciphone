//
//  LineObjectView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/1/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "LineObjectView.h"
#import "LineObject.h"
#import "SharedUtility.h"

#define DEFAULT_BASE_COLOR [UIColor blueColor]
#define DEFAULT_SELECTED_COLOR [UIColor whiteColor]

@implementation LineObjectView

@synthesize parent, circleRadius, localStart, localEnd, startTouch, endTouch, baseColor, currentColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        circleRadius = 10;
		//downTouches = [[NSMutableArray array] retain];
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.userInteractionEnabled = NO;
		self.baseColor = DEFAULT_BASE_COLOR;
		self.currentColor = self.baseColor;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame startPoint:(CGPoint)theLocalStart endPoint:(CGPoint)theLocalEnd radius:(float)theRadius
{
	if(self = [self initWithFrame:frame])
	{
		circleRadius = theRadius;
		localStart = theLocalStart;
		localEnd = theLocalEnd;
	}
	
	return self;
}


- (void)drawRect:(CGRect)rect {
	UIColor * theColor = self.currentColor;
	float red = [SharedUtility getRedFromColor:theColor];
	float green = [SharedUtility getGreenFromColor:theColor];
	float blue = [SharedUtility getBlueFromColor:theColor];
	float alpha = [SharedUtility getAlphaFromColor:theColor];
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(contextRef, red, green, blue, alpha);
	CGContextSetRGBStrokeColor(contextRef, red, green, blue, 0.75*alpha);
	
	[self drawCircleAtPoint:localStart withRadius:circleRadius inContext: contextRef];
	[self drawCircleAtPoint:localEnd withRadius:circleRadius inContext: contextRef];
	
	CGContextMoveToPoint(contextRef, localStart.x, localStart.y);
	CGContextSetLineWidth (contextRef, 10.0);
	CGContextAddLineToPoint( contextRef, localEnd.x, localEnd.y);
	CGContextStrokePath(contextRef);
}

- (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext
{
	CGContextFillEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
	CGContextStrokeEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
}

+ (LineObjectView*) lineViewOnParentView:(UIView*)parentView withParentStart:(CGPoint)parentStart parentEnd:(CGPoint)parentEnd radius:(float)theRadius;
{
	/*
	CGPoint theOrigin = CGPointMake(MIN(parentStart.x, parentEnd.x) - theRadius, MIN(parentStart.y, parentEnd.y) - theRadius);
	float width = fabs(parentStart.x - parentEnd.x) + 2*theRadius;
	float height = fabs(parentStart.y - parentEnd.y) + 2*theRadius;
	
	CGPoint theLocalStart = CGPointMake(parentStart.x - theOrigin.x, parentStart.y - theOrigin.y);
	CGPoint theLocalEnd = CGPointMake(parentEnd.x - theOrigin.x, parentEnd.y - theOrigin.y);
	CGRect frameToBe = parentView.frame;//CGRectMake(theOrigin.x, theOrigin.y, width, height)
	 */
	
	return [[[LineObjectView alloc] initWithFrame:CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height) startPoint:parentStart endPoint:parentEnd radius:theRadius] autorelease];
}

- (void) trackTouches:(NSSet*)touches
{
	for(UITouch * touch in touches)
	{
		if(!startBeingDragged)
		{
			if([self touchStartRelevant:touch])
			{
				//[downTouches addObject:touch];
				startBeingDragged = YES;
				self.startTouch = touch;
			}
		}
		
		if(!endBeingDragged)
		{
			if([self touchEndRelevant:touch])
			{
				//[downTouches addObject:touch];
				endBeingDragged = YES;
				self.endTouch = touch;
			}
		}
	}
}

- (NSMutableSet*) relevantTouches:(NSSet*)touches
{
	NSMutableSet * result = [NSMutableSet setWithCapacity:0];
	
	for(UITouch * touch in touches)
	{
		if([self touchIsRelevant:touch])
		{
			[result addObject:touch];
		}
	}
	
	return result;
}

- (NSMutableSet*) trackedTouches
{
	NSMutableSet * relevant = [NSMutableSet setWithCapacity:2];
	if(startTouch != nil)
	{
		[relevant addObject:startTouch];
	}
	if(endTouch != nil)
	{
		[relevant addObject:endTouch];
	}
	return relevant;
	//return downTouches;
}

- (BOOL) stopTrackingTouches:(NSSet*)touches
{
	if([touches containsObject:startTouch])
	{
		startBeingDragged = NO;
		self.startTouch = nil;
	}
	
	if([touches containsObject:endTouch])
	{
		endBeingDragged = NO;
		self.endTouch = nil;
	}
	
	return startTouch == nil && endTouch == nil;
	/*
	NSMutableArray * toTrash = [NSMutableArray array];

	for(UITouch * touch in downTouches)
	{
		if([touches containsObject:touch])
		{
			if(startBeingDragged)
			{
				if([touch isEqual:[self touchRelevantToPoint:localStart outOf:downTouches]])
				{
					startBeingDragged = NO;
				}
			}
			
			if(endBeingDragged)
			{
				if([touch isEqual:[self touchRelevantToPoint:localEnd outOf:downTouches]])
				{
					endBeingDragged = NO;
				}
			}
			[toTrash addObject:touch];
		}
	}
	
	for(UITouch * touch in toTrash)
	{
		[downTouches removeObject:touch];
	}
	
	return [downTouches count] == 0;
	 */
}

- (BOOL) touchStartRelevant:(UITouch*)touch
{
	CGPoint touchPoint = [touch locationInView:self];
	return [SharedUtility distanceFrom:touchPoint to:localStart] < circleRadius;
}

- (BOOL) touchEndRelevant:(UITouch*)touch
{
	CGPoint touchPoint = [touch locationInView:self];
	return [SharedUtility distanceFrom:touchPoint to:localEnd] < circleRadius;
}

- (BOOL) touchIsRelevant:(UITouch*)touch
{
	BOOL startRelevant = [self touchStartRelevant:touch];
	BOOL endRelevant = [self touchEndRelevant:touch];
	
	return startRelevant || endRelevant;
}

- (BOOL) touchesAreRelevant:(NSSet*)touches
{
	return [self relevantTouches:touches] > 0;
}

- (void) updateSelected
{
	self.currentColor = DEFAULT_SELECTED_COLOR;
	[self setNeedsDisplay];
}

- (void) updateUnselected
{
	self.currentColor = self.baseColor;
	[self setNeedsDisplay];
}

- (void) readjustFrame
{
	CGPoint theOrigin = CGPointMake(MIN(localStart.x, localEnd.x) - circleRadius, MIN(localStart.y, localEnd.y) - circleRadius);
	float width = fabs(localStart.x - localEnd.x) + 2*circleRadius;
	float height = fabs(localStart.y - localEnd.y) + 2*circleRadius;
	
	self.frame = CGRectMake(theOrigin.x, theOrigin.y, width, height);
}


- (UITouch*) touchRelevantToPoint:(CGPoint)thePoint outOf:(NSSet*)touches
{
	float currentMin = 10000000000;
	UITouch * best = nil;
	for(UITouch * touch in touches)
	{
		CGPoint touchPoint = [touch locationInView:self];
		float currentDist = [SharedUtility distanceFrom:touchPoint to:thePoint];
		if(currentDist < currentMin)
		{
			currentMin = currentDist;
			best = touch;
		}
	}
	
	return best;
}

- (void) updateForTouches:(NSSet*)touches
{
	if([touches count] == 1 && startBeingDragged && endBeingDragged)
	{
		UITouch * touch = [touches anyObject];
		CGPoint touchPoint = [touch locationInView:self];
		if([touch isEqual:startTouch])
		{
			localStart = touchPoint;
		}else if([touch isEqual:endTouch])
		{
			localEnd = touchPoint;
		}

		[self setNeedsDisplay];
		return;
	}
	
	if(startBeingDragged)
	{
		//UITouch * theTouch = [self touchRelevantToPoint:localStart outOf:downTouches];
		UITouch * theTouch = startTouch;
		localStart = [theTouch locationInView:self];
		[self setNeedsDisplay];
	}
	
	if(endBeingDragged)
	{
		//UITouch * theTouch = [self touchRelevantToPoint:localEnd outOf:downTouches];
		UITouch * theTouch = endTouch;
		localEnd = [theTouch locationInView:self];
		[self setNeedsDisplay];
	}
}


- (void)dealloc {
	//[downTouches release];
	[currentColor release];
	[baseColor release];
	[startTouch release];
	[endTouch release];
	
    [super dealloc];
}


@end
