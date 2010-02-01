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
	SharedObject * currentlyManipulated;
}

- (IBAction)showInfo;

- (CGPoint) percentCoordsForTouch:(UITouch*)theTouch;

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
