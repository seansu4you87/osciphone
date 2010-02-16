//
//  MainViewController.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "ObjectSettingsViewController.h"

@class EAGLView, AudioManager, MultiPointController, SequencerController;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, ObjectSettingsViewControllerDelegate> {

	IBOutlet EAGLView * glView;
	IBOutlet UIButton * infoButton;
	IBOutlet UIButton * switchButton;
	AudioManager * audioManager;
	MultiPointController * multiController;
	SequencerController * sequenceController;
	BOOL pointMode;
}

- (IBAction)showInfo;
- (IBAction)switchView;

- (void) allowSwitch;
- (void) refuseSwitch;

- (void) allowInfo;
- (void) refuseInfo;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) startAnimation;
- (void) stopAnimation;

@end
