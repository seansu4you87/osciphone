//
//  FlipsideViewController.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UITextField * portTextField;
	IBOutlet UITextField * ipTextField;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done;
- (void)ipChanged;
- (void)portChanged;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

