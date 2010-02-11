//
//  OSCLaserAppDelegate.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "OSCLaserAppDelegate.h"
#import "MainViewController.h"

@implementation OSCLaserAppDelegate

@synthesize window;
@synthesize mainViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
	
	[mainViewController startMainThread];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
