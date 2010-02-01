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

@synthesize parent, circleRadius;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        circleRadius = 10;
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
}

- (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext
{
	CGContextFillEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
	CGContextStrokeEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
}

+ (LineObjectView*) lineViewOnParentView:(UIView*)parentView withParentStart:(CGPoint)parentStart parentEnd:(CGPoint)parentEnd radius:(float)theRadius;
{
	CGPoint theOrigin = CGPointMake(MIN(parentStart.x, parentEnd.x) - theRadius, MIN(parentStart.y, parentEnd.y) - theRadius);
	float width = fabs(parentStart.x - parentEnd.x) + 2*theRadius;
	float height = fabs(parentStart.y - parentEnd.y) + 2*theRadius;
	
	CGPoint theLocalStart = CGPointMake(parentStart.x - theOrigin.x, parentStart.y - theOrigin.y);
	CGPoint theLocalEnd = CGPointMake(parentEnd.x - theOrigin.x, parentEnd.y - theOrigin.y);
	
	return [[[LineObjectView alloc] initWithFrame:CGRectMake(theOrigin.x, theOrigin.y, width, height) startPoint:theLocalStart endPoint:theLocalEnd radius:theRadius] autorelease];
}

+ (float) distanceFrom:(CGPoint)fromPoint to:(CGPoint)toPoint
{
	return sqrt(pow(fromPoint.x - toPoint.x, 2) + pow(fromPoint.y - toPoint.y, 2));
}

- (BOOL) touchesAreRelevant:(NSSet*)touches
{
	for(UITouch * touch in touches)
	{
		CGPoint touchPoint = [touch locationInView:self];
		BOOL startRelevant = [LineObjectView distanceFrom:touchPoint to:localStart] < circleRadius;
		BOOL endRelevant = [LineObjectView distanceFrom:touchPoint to:localEnd] < circleRadius;
		if(startRelevant || endRelevant)
		{
			return YES;
		}
	}
	
	return NO;
}


- (void)dealloc {
    [super dealloc];
}


@end
