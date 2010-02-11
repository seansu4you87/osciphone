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
	
	//NSMutableSet * downTouches;
	UITouch * startTouch;
	UITouch * endTouch;
	
	UIColor * baseColor;
	UIColor * currentColor;
}

@property(nonatomic, assign) LineObject * parent;
@property(nonatomic, assign) float circleRadius;
@property(nonatomic, readonly) CGPoint localStart, localEnd;
@property(nonatomic, retain) UITouch *startTouch, *endTouch;
@property(nonatomic, retain) UIColor *baseColor, *currentColor;

- (id) initWithFrame:(CGRect)frame startPoint:(CGPoint)theLocalStart endPoint:(CGPoint)theLocalEnd radius:(float)theRadius;
+ (LineObjectView*) lineViewOnParentView:(UIView*)parentView withParentStart:(CGPoint)parentStart parentEnd:(CGPoint)parentEnd radius:(float)theRadius;

- (BOOL) touchIsRelevant:(UITouch*)touch;
- (BOOL) touchesAreRelevant:(NSSet*)touches;
- (void) updateForTouches:(NSSet*)touches;
- (void) trackTouches:(NSSet*)touches;
- (BOOL) stopTrackingTouches:(NSSet*)touches;
- (BOOL) touchStartRelevant:(UITouch*)touch;
- (BOOL) touchEndRelevant:(UITouch*)touch;
- (UITouch*) touchRelevantToPoint:(CGPoint)thePoint outOf:(NSSet*)touches;
- (NSMutableSet*) relevantTouches:(NSSet*)touches;
- (NSMutableSet*) trackedTouches;
- (void) updateSelected;
- (void) updateUnselected;


@end
