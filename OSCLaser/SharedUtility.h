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
+ (float) PI;

//color functions
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorFromColor:(UIColor*)color andAlpha:(float)alpha;
+ (float) getRedFromColor:(UIColor*)theColor;
+ (float) getGreenFromColor:(UIColor*)theColor;
+ (float) getBlueFromColor:(UIColor*)theColor;
+ (float) getAlphaFromColor:(UIColor*)theColor;

//cg drawing
+ (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext;

@end
