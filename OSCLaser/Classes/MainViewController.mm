//
//  MainViewController.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "OSCConfig.h"
#import "OSCPort.h"
#import "EAGLView.h"
#import "AudioManager.h"
#import "MultiPointObject.h"
#import "MultiPointController.h"
#import "SequencerController.h"
#import "SharedCollection.h"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [SharedCollection sharedCollection];
		[Sequencer sharedSequencer];
		[AudioManager sharedManager];
		
		pointMode = YES;
    }
    return self;
}

#pragma mark physics/animation toggles

- (void) startAnimation
{
	[glView startAnimation];
	[[AudioManager sharedManager] muteOff];
}

- (void) stopAnimation
{
	[glView stopAnimation];
	[[AudioManager sharedManager] muteOn];
}

#pragma mark button toggles

- (void) allowSwitch
{
	switchButton.hidden = NO;
}
- (void) refuseSwitch
{
	switchButton.hidden = YES;
}

- (void) allowInfo
{
	infoButton.hidden = NO;
}

- (void) refuseInfo
{
	infoButton.hidden = YES;
}

#pragma mark viewController logic

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 MainView * myView = (MainView*)(self.view);
	 myView.parent = self;
	 /*
	 OSCConfig * theConfig = [OSCConfig sharedConfig];
	 if(![theConfig isConfigured])
	 {
		 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must configure network settings before OSC events will be sent. Please click the info button." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		 [alert show];
		 [alert release];
	 }
	 */
	 [self.view bringSubviewToFront:infoButton];
	 [self.view bringSubviewToFront:switchButton];
	 
	 [[AudioManager sharedManager] startCallback];
	 
	 multiController = [[MultiPointController alloc] initWithParentView:self.view];
	 multiController.mainView = self;
 }
 


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */



- (void)flipsideViewDidLoad:(FlipsideViewController *)controller
{
	[self stopAnimation];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
	[self startAnimation];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)objectsSettingsViewDidLoad:(ObjectSettingsViewController *)controller
{
	[self stopAnimation];
}

- (void)objectsSettingsViewControllerDidFinish:(ObjectSettingsViewController *)controller
{
	[self startAnimation];
	[self dismissModalViewControllerAnimated:YES];
}


- (void) showOSCSettings
{
	[self stopAnimation];
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	//controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}



- (IBAction)showInfo {    
	[self stopAnimation];
	ObjectSettingsViewController *controller = [[ObjectSettingsViewController alloc] initWithNibName:@"ObjectSettingsView" bundle:nil andObject:(MultiPointObject*)(multiController.selected)];
	controller.delegate = self;
	
	//controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (IBAction)switchView
{
	if(![glView isMoving])
	{
		if(pointMode)
		{
			if(sequenceController == nil)
			{
				sequenceController = [[SequencerController alloc] initWithParentView:self.view];
			}
			[glView switchToSequencer];
		}else{
			[glView switchToPoints];
		}
		
		pointMode = !pointMode;
	}
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[SharedCollection releaseCollection];
	
    [super dealloc];
}

#pragma mark touch responders

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent*)event
{
	if(pointMode)
	{
		[multiController touchesEnded:touches withEvent:event];
	}else{
		[sequenceController touchesEnded:touches withEvent:event];
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event
{
	if(pointMode)
	{
		[multiController touchesMoved:touches withEvent:event];
	}else{
		[sequenceController touchesMoved:touches withEvent:event];
	}
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event
{
	if(pointMode)
	{
		if([touches count] == 3)
		{
			for(UITouch * touch in touches)
			{
				if([touch tapCount] == 3)
				{
					[self showOSCSettings];
					return;
				}
			}
		}
		[multiController touchesBegan:touches withEvent:event];
	}else{
		[sequenceController touchesBegan:touches withEvent:event];
	}
}

@end
