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

+ (UIColor *)darkerColorFromColor:(UIColor*)color darkFactor:(float)darkFactor
{
	float red = [SharedUtility getRedFromColor:color];
	float green = [SharedUtility getGreenFromColor:color];
	float blue = [SharedUtility getBlueFromColor:color];
	float alpha = [SharedUtility getAlphaFromColor:color];
	
	return [UIColor colorWithRed:red*darkFactor green:green*darkFactor blue:blue*darkFactor alpha:alpha];
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

+ (float) PI
{
	return 3.141592653589793;
}

+ (CGPoint) point:(CGPoint)firstPoint minusPoint:(CGPoint)subtractPoint
{
	return CGPointMake(firstPoint.x - subtractPoint.x, firstPoint.y - subtractPoint.y);
}

+ (float) dotProductBetweenVector:(CGPoint)vectorOne andVector:(CGPoint)vectorTwo
{
	return vectorOne.x*vectorTwo.x + vectorOne.y*vectorOne.y;
}

+ (float) radiansToDegrees:(float)radians
{
	return 360.0*radians/(2*[SharedUtility PI]);
}

+ (float) degreeAngleBetweenVector:(CGPoint)vectorOne andVector:(CGPoint)vectorTwo
{
	return [SharedUtility radiansToDegrees:[SharedUtility radianAngleBetweenVector:vectorOne andVector:vectorTwo]];
}

+ (float) radianAngleBetweenVector:(CGPoint)vectorOne andVector:(CGPoint)vectorTwo
{
	float cosineValue = [SharedUtility dotProductBetweenVector:vectorOne andVector:vectorTwo]/([SharedUtility magnitudeOf:vectorOne]*[SharedUtility magnitudeOf:vectorTwo]);
	float angleValue = acos(cosineValue);
	//NSLog(@"cos: %f theta: %f", cosineValue, angleValue);
	return angleValue;
}

+ (float)randfBetween:(float)a andUpper:(float)b
{
    float diff = b - a;
    return a + ((float)rand() / RAND_MAX)*diff;
}

+ (int)randBetween:(int)a andUpper:(int)b
{
    int diff = b - a;
    return a + (rand() % (diff+1));
}

+ (float)mtof:(int)mid
{
	return 440 * pow(2, ((float)(mid-69)/12));
}

#pragma mark CG drawing

+ (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext
{
	CGContextFillEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
	CGContextStrokeEllipseInRect(theContext, CGRectMake(thePoint.x - theRadius, thePoint.y - theRadius, theRadius*2, theRadius*2));
}


@end
