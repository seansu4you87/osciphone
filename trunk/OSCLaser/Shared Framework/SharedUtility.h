//
//  SharedUtility.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SharedUtility : NSObject {

}

//math
+ (float) distanceFrom:(CGPoint)fromPoint to:(CGPoint)toPoint;
+ (float) magnitudeOf:(CGPoint)thePoint;
+ (CGPoint) point:(CGPoint)firstPoint minusPoint:(CGPoint)subtractPoint;
+ (float) PI;

+ (float) radiansToDegrees:(float)radians;
+ (float) dotProductBetweenVector:(CGPoint)vectorOne andVector:(CGPoint)vectorTwo;
+ (float) degreeAngleBetweenVector:(CGPoint)vectorOne andVector:(CGPoint)vectorTwo;
+ (float) radianAngleBetweenVector:(CGPoint)vectorOne andVector:(CGPoint)vectorTwo;

+ (float)randfBetween:(float)a andUpper:(float)b;
+ (int)randBetween:(int)a andUpper:(int)b;
+ (float)mtof:(int)mid;


//color functions
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorFromColor:(UIColor*)color andAlpha:(float)alpha;
+ (UIColor *)darkerColorFromColor:(UIColor*)color darkFactor:(float)darkFactor;
+ (float) getRedFromColor:(UIColor*)theColor;
+ (float) getGreenFromColor:(UIColor*)theColor;
+ (float) getBlueFromColor:(UIColor*)theColor;
+ (float) getAlphaFromColor:(UIColor*)theColor;

//cg drawing
+ (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext;

@end
