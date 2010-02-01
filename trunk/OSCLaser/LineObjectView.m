//
//  LineObjectView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/1/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "LineObjectView.h"
#import "LineObject.h"

@implementation LineObjectView

@synthesize parent, circleRadius, localStart, localEnd;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        circleRadius = 10;
		downTouches = [[NSMutableArray array] retain];
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.userInteractionEnabled = NO;
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
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(contextRef, 0, 0, 1.0, 0.75);
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 1.0, 0.5);
	
	[self drawCircleAtPoint:localStart withRadius:circleRadius inContext: contextRef];
	[self drawCircleAtPoint:localEnd withRadius:circleRadius inContext: contextRef];
	
	CGContextMoveToPoint(contextRef, localStart.x, localStart.y);
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
				[downTouches addObject:touch];
				startBeingDragged = YES;
			}
		}
		
		if(!endBeingDragged)
		{
			if([self touchEndRelevant:touch])
			{
				[downTouches addObject:touch];
				endBeingDragged = YES;
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
	return downTouches;
}

- (BOOL) stopTrackingTouches:(NSSet*)touches
{
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
}

+ (float) distanceFrom:(CGPoint)fromPoint to:(CGPoint)toPoint
{
	return sqrt(pow(fromPoint.x - toPoint.x, 2) + pow(fromPoint.y - toPoint.y, 2));
}

- (BOOL) touchStartRelevant:(UITouch*)touch
{
	CGPoint touchPoint = [touch locationInView:self];
	return [LineObjectView distanceFrom:touchPoint to:localStart] < circleRadius;
}

- (BOOL) touchEndRelevant:(UITouch*)touch
{
	CGPoint touchPoint = [touch locationInView:self];
	return [LineObjectView distanceFrom:touchPoint to:localEnd] < circleRadius;
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
		float currentDist = [LineObjectView distanceFrom:touchPoint to:thePoint];
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
		
		float startDistance = [LineObjectView distanceFrom:touchPoint to:localStart];
		float endDistance = [LineObjectView distanceFrom:touchPoint to:localEnd];
		if(startDistance < endDistance)
		{
			localStart = touchPoint;
		}else{
			localEnd = touchPoint;
		}
		[self setNeedsDisplay];
		return;
	}
	
	if(startBeingDragged)
	{
		UITouch * theTouch = [self touchRelevantToPoint:localStart outOf:downTouches];
		localStart = [theTouch locationInView:self];
		[self setNeedsDisplay];
	}
	
	if(endBeingDragged)
	{
		UITouch * theTouch = [self touchRelevantToPoint:localEnd outOf:downTouches];
		localEnd = [theTouch locationInView:self];
		[self setNeedsDisplay];
	}
}


- (void)dealloc {
	[downTouches release];
	
    [super dealloc];
}


@end
