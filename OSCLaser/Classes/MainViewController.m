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

@synthesize startTouch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        collection = [[SharedCollection alloc] init];
		currentlyManipulated = [[NSMutableSet setWithCapacity:0] retain];
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
	[currentlyManipulated release];
    [super dealloc];
}

#pragma mark touch responders
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"stopped tracking %d touches", [touches count]);
	if([touches count] == 1)
	{
		UITouch * touch = [touches anyObject];
		if([touch isEqual:startTouch])
		{
			self.startTouch = nil;
		}
	}
	
	NSMutableSet * toTrash = [NSMutableSet setWithCapacity:0];
	for(SharedObject * cur in currentlyManipulated)
	{
		if([cur stopTrackingTouches:touches])
		{
			[toTrash addObject:cur];
		}
	}
	
	for(SharedObject * cur in toTrash)
	{
		[currentlyManipulated removeObject:cur];
	}
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
	//NSLog(@"%d touches moving", [touches count]);
	for(SharedObject * cur in currentlyManipulated)
	{
		[cur updateForTouches:touches];
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%d touches beginning", [touches count]);

	NSArray * allObjects = [collection objects];
	BOOL anyRelevant = NO;
	
	//consider prepopulating takenTouches with the contents of all manipulated objects' downTouches field
	NSMutableSet * takenTouches = [NSMutableSet setWithCapacity:0];
	for(SharedObject * curObject in allObjects)
	{
		NSMutableSet * curRelevantTouches = [curObject relevantTouches:touches];
		if([curRelevantTouches count] > 0)
		{
			NSMutableSet * allowableTouches = [NSMutableSet setWithCapacity:0];
			for(UITouch * touch in curRelevantTouches)
			{
				if(![takenTouches containsObject:touch])
				{
					[allowableTouches addObject:touch];
				}
			}
			
			if([allowableTouches count] > 0)
			{
				[currentlyManipulated addObject:curObject];
				[curObject trackTouches:allowableTouches];
				[takenTouches unionSet:allowableTouches];
				anyRelevant = YES;
			}
		}
	}
	
   if(anyRelevant)
   {
	   return;
   }
	
	NSMutableSet * touchesLeft = [NSMutableSet setWithSet:touches];
	[touchesLeft minusSet:touch
	   
	if([touches count] == 1)
	{
		if(startTouch == nil)
		{
			UITouch * theTouch = [touches anyObject];
			self.startTouch = theTouch;
		}else {
			UITouch * theTouch = [touches anyObject];
			
			LineObject * newLine = [[LineObject alloc] initOnView:self.view withStartPoint:[startTouch locationInView:self.view] endPoint:[theTouch locationInView:self.view]];
			[collection addSharedObject:[newLine autorelease]];
			[currentlyManipulated addObject:newLine];
			[newLine trackTouches:[NSMutableSet setWithObjects:theTouch, startTouch, nil]];
		}
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
		[collection addSharedObject:[newLine autorelease]];
		[currentlyManipulated addObject: newLine];
		[newLine trackTouches:touches];
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
