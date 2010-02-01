//
//  LineObjectView.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/1/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LineObject;

@interface LineObjectView : UIView {
	LineObject * parent;
	float circleRadius;
	
	CGPoint localStart;
	CGPoint localEnd;
	
	BOOL startBeingDragged;
	BOOL endBeingDragged;
}

@property(nonatomic, assign) LineObject * parent;
@property(nonatomic, assign) float circleRadius;
@property(nonatomic, readonly) CGPoint localStart, localEnd;

- (id) initWithFrame:(CGRect)frame startPoint:(CGPoint)theLocalStart endPoint:(CGPoint)theLocalEnd radius:(float)theRadius;
+ (LineObjectView*) lineViewOnParentView:(UIView*)parentView withParentStart:(CGPoint)parentStart parentEnd:(CGPoint)parentEnd radius:(float)theRadius;

- (void) drawCircleAtPoint:(CGPoint)thePoint withRadius:(float)theRadius inContext:(CGContextRef)theContext;
- (BOOL) touchIsRelevant:(UITouch*)touch;
- (BOOL) touchesAreRelevant:(NSSet*)touches;
- (void) updateForTouches:(NSSet*)touches;
- (void) trackTouches:(NSSet*)touches;
- (void) stopTrackingTouches;
- (BOOL) touchStartRelevant:(UITouch*)touch;
- (BOOL) touchEndRelevant:(UITouch*)touch;

@end
