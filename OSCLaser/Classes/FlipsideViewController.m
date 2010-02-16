//
//  FlipsideViewController.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "OSCConfig.h"

@implementation FlipsideViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	OSCConfig * theConfig = [OSCConfig sharedConfig];
	if([theConfig ipIsConfigured])
	{
		ipTextField.text = theConfig.ip;
	}
	if([theConfig portIsConfigured])
	{
		portTextField.text = [NSString stringWithFormat:@"%d", theConfig.port];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if([textField isEqual:portTextField])
	{
		[self portEditingDone];
	}else if([textField isEqual:ipTextField])
	{
		[self ipEditingDone];
	}
	
	return YES;
}

- (IBAction) ipEditingBegin
{
	OSCConfig * theConfig = [OSCConfig sharedConfig];
	if([theConfig ipIsConfigured])
	{
		ipTextField.text = theConfig.ip;
	}
}

- (IBAction) portEditingBegin
{
	OSCConfig * theConfig = [OSCConfig sharedConfig];
	if([theConfig portIsConfigured])
	{
		portTextField.text = [NSString stringWithFormat:@"%d", theConfig.port];
	}
}

- (IBAction) ipEditingDone
{
	[self ipChanged];
	[portTextField becomeFirstResponder];
}

- (IBAction) portEditingDone
{
	[self portChanged];
	[portTextField resignFirstResponder];
	[self done];
}

- (IBAction)done {
	[self ipChanged];
	[self portChanged];
	[self.delegate flipsideViewControllerDidFinish:self];
}

- (void) ipChanged
{
	OSCConfig * theConfig = [OSCConfig sharedConfig];
	[theConfig setIP:ipTextField.text];
}

- (void) portChanged
{
	OSCConfig * theConfig = [OSCConfig sharedConfig];
	[theConfig setPort:[portTextField.text intValue]];
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
    [super dealloc];
}


@end
