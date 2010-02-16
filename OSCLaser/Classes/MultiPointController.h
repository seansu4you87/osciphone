//
//  MultiPointController.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SharedCollection, SharedObject, MainViewController;

@interface MultiPointController : NSObject {
	MainViewController * mainView;
	NSMutableSet * downTouches;
	NSMutableSet * currentlyManipulated;
	SharedObject * selected;
	
	UITouch * startTouch;
	NSTimer * touchTimer;
	int colorIndex;
	
	UIView * parentView;
}

@property(nonatomic, retain) UITouch * startTouch;
@property(nonatomic, retain) SharedObject * selected;
@property(nonatomic, retain) NSTimer * touchTimer;
@property(nonatomic, assign) MainViewController * mainView;

- (id) initWithParentView:(UIView*)theParentView;

- (void) addManipulatedObject:(SharedObject*)theObject withTouches:(NSMutableSet*)manipulatingTouches;
- (void) addSharedObject:(SharedObject*)theObject withTouches:(NSMutableSet*) creatingTouches;
- (void) removeSelectedObject;
- (void) removeTouchTimer;
- (BOOL) isTouchControllingAnything:(UITouch*)theTouch;

- (UIColor*) colorForIndex:(int)objIndex;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
