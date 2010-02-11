//
//  MultiPointObjectView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "MultiPointObjectView.h"
#import "MultiPointObject.h"
#import "ControlPoint.h"
#import "SharedUtility.h"

@implementation MultiPointObjectView

@synthesize parentObject;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.userInteractionEnabled = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	if(parentObject != nil)
	{
		UIColor * theColor = [UIColor greenColor];
		float red = [SharedUtility getRedFromColor:theColor];
		float green = [SharedUtility getGreenFromColor:theColor];
		float blue = [SharedUtility getBlueFromColor:theColor];
		float alpha = [SharedUtility getAlphaFromColor:theColor];
		
		CGContextRef contextRef = UIGraphicsGetCurrentContext();
		
		CGContextSetRGBFillColor(contextRef, red, green, blue, alpha);
		CGContextSetRGBStrokeColor(contextRef, red, green, blue, 0.75*alpha);
		
		NSArray * controlPoints = [parentObject getControlPoints];
		for(ControlPoint * point in controlPoints)
		{
			[SharedUtility drawCircleAtPoint:point.position withRadius:point.radius inContext: contextRef];
		}
		/*
		CGContextMoveToPoint(contextRef, localStart.x, localStart.y);
		CGContextSetLineWidth (contextRef, 10.0);
		CGContextAddLineToPoint( contextRef, localEnd.x, localEnd.y);
		CGContextStrokePath(contextRef);
		 */
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
