//
//  MainViewController.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "FlipsideViewController.h"

@class SharedCollection, SharedObject
;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	SharedCollection * collection;
	NSMutableSet * downTouches;
	NSMutableSet * currentlyManipulated;
	SharedObject * selected;
	UITouch * startTouch;
}

@property(nonatomic, retain) UITouch * startTouch;
@property(nonatomic, retain) SharedObject * selected;

- (IBAction)showInfo;

- (CGPoint) percentCoordsForTouch:(UITouch*)theTouch;
- (void) addLineForStartTouch:(UITouch*)touchOne endTouch:(UITouch*)touchTwo;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) addManipulatedObject:(SharedObject*)theObject withTouches:(NSMutableSet*)manipulatingTouches;
- (void) addSharedObject:(SharedObject*)theObject withTouches:(NSMutableSet*) creatingTouches;
- (void) removeSelectedObject;

- (void) startMainThread;

@end
