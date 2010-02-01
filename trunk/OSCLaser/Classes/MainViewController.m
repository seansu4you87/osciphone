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
#import "SharedCollection.h"
#import "LineObject.h"

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        collection = [[SharedCollection alloc] init];
    }
    return self;
}



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 MainView * myView = (MainView*)(self.view);
	 myView.parent = self;
	 OSCConfig * theConfig = [OSCConfig sharedConfig];
	 if(![theConfig isConfigured])
	 {
		 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must configure network settings before OSC events will be sent. Please click the info button." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		 [alert show];
		 [alert release];
	 }
 }
 


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
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
	[collection release];
    [super dealloc];
}

#pragma mark touch responders
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[currentlyManipulated stopTrackingTouches];
	currentlyManipulated = nil;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
	[currentlyManipulated updateForTouches:touches];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	
	NSArray * allObjects = [collection objects];
	BOOL anyRelevant = NO;
	for(SharedObject * curObject in allObjects)
	{
		if(!anyRelevant)
		{
			if([curObject touchesAreRelevant:touches])
			{
				currentlyManipulated = curObject;
				[currentlyManipulated trackTouches:touches];
				anyRelevant = YES;
		   }
		}
	}
	
   if(anyRelevant)
   {
	   return;
   }
	
	currentlyManipulated = nil;
	
	NSLog(@"began %d touches", [touches count]);
		   
	if([touches count] == 1)
	{
		UITouch * theTouch = [touches anyObject];
		CGPoint percentCoords = [self percentCoordsForTouch:theTouch];
		[thePort sendTo:[[NSString stringWithFormat:@"/begin1"]UTF8String] types:"ff", percentCoords.x, percentCoords.y];
	}else if([touches count] == 2)
	{
		NSMutableArray * orderedTouches = [NSMutableArray arrayWithCapacity:2];
		for(UITouch * curTouch in touches)
		{
			[orderedTouches addObject:curTouch];
		}
		UITouch * firstTouch = [orderedTouches objectAtIndex:0];
		UITouch * secondTouch = [orderedTouches objectAtIndex:1];
		
		LineObject * newLine = [[LineObject alloc] initOnView:self.view withStartPoint:[firstTouch locationInView:self.view] endPoint:[secondTouch locationInView:self.view]];
		[collection addSharedObject:newLine];
	}
}

- (CGPoint) percentCoordsForTouch:(UITouch*)theTouch
{
	CGPoint viewCoord = [theTouch locationInView:self.view];
	
	float xPercent = viewCoord.x/self.view.frame.size.width;
	float yPercent = viewCoord.y/self.view.frame.size.height;
	
	return CGPointMake(xPercent, yPercent);
}


@end
