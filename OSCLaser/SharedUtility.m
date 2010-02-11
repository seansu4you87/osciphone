//
//  SharedUtility.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SharedUtility.h"


@implementation SharedUtility

#pragma mark colors

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
}

+ (float) getRedFromColor:(UIColor*)theColor
{
	const CGFloat * components = CGColorGetComponents(theColor.CGColor);
	return *components;
}

+ (float) getGreenFromColor:(UIColor*)theColor
{
	const CGFloat * components = CGColorGetComponents(theColor.CGColor);
	return *(components + 1);
}

+ (float) getBlueFromColor:(UIColor*)theColor
{
	const CGFloat * components = CGColorGetComponents(theColor.CGColor);
	return *(components + 2);
}

+ (float) getAlphaFromColor:(UIColor*)theColor
{
	return CGColorGetAlpha(theColor.CGColor);
}

+ (UIColor*) colorFromColor:(UIColor*)theColor andAlpha:(float)newAlpha
{
	return [UIColor colorWithRed:[SharedUtility getRedFromColor:theColor] green:[SharedUtility getGreenFromColor:theColor] blue:[SharedUtility getBlueFromColor:theColor] alpha:newAlpha];
}

#pragma mark math

+ (float) distanceFrom:(CGPoint)fromPoint to:(CGPoint)toPoint
{
	return sqrt(pow(fromPoint.x - toPoint.x, 2) + pow(fromPoint.y - toPoint.y, 2));
}

+ (float) magnitudeOf:(CGPoint)thePoint
{
	return [SharedUtility distanceFrom:thePoint to:CGPointZero];
}

#pragma mark CG drawing

+ (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext
{
	CGContextFillEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
	CGContextStrokeEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
}


@end
