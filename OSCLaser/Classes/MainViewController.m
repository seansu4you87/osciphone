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

@synthesize startTouch, selected;

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
	[selected release];
	[collection release];
	[currentlyManipulated release];
    [super dealloc];
}

#pragma mark touch responders
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([currentlyManipulated count] == 0)
	{
		self.selected = nil;
	}
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
		[cur updateUnselected];
		if([currentlyManipulated count] == 1)
		{
			self.selected = cur;
		}
		
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

- (void) setSelected:(SharedObject*)theObject
{
	[selected updateUnselected];
	[selected release];
	selected = [theObject retain];
	[theObject updateSelected];	
}

- (void) addManipulatedObject:(SharedObject*)theObject withTouches:(NSMutableSet*)manipulatingTouches
{
	if([currentlyManipulated count] == 0)
	{
		self.selected = theObject;
	}
	
	[currentlyManipulated addObject: theObject];
	[theObject trackTouches:manipulatingTouches];
	[theObject updateSelected];
}

- (void) addSharedObject:(SharedObject*)theObject withTouches:(NSMutableSet*) creatingTouches
{
	[collection addSharedObject:theObject];
	[self addManipulatedObject:theObject withTouches:creatingTouches];	
}

- (void) removeObject:(SharedObject*)theObject
{
	if([currentlyManipulated containsObject:theObject])
	{
		[currentlyManipulated removeObject:theObject];
	}
	[collection removeSharedObject:theObject];
	[theObject.objectView removeFromSuperview];
	if(theObject == selected)
	{
		self.selected = nil;
	}
}

- (void) removeSelectedObject
{
	if(selected != nil)
	{
		[self removeObject:selected];
		//self.selected = nil;
	}
}

- (void) addLineForStartTouch:(UITouch*)touchOne endTouch:(UITouch*)touchTwo
{
	LineObject * newLine = [[LineObject alloc] initOnView:self.view withStartPoint:[touchOne locationInView:self.view] endPoint:[touchTwo locationInView:self.view]];
	[self addSharedObject:newLine withTouches:[NSMutableSet setWithObjects:touchOne, touchTwo, nil]];
	[newLine release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([touches count] == 1)
	{
		UITouch * theTouch = [touches anyObject];
		if([theTouch tapCount] > 1)
		{
			[self removeSelectedObject];
			return;
		}
	}
	//NSLog(@"%d touches beginning", [touches count]);

	NSArray * allObjects = [collection objects];
	
	//consider prepopulating takenTouches with the contents of all manipulated objects' downTouches field
	NSMutableSet * takenTouches = [NSMutableSet setWithCapacity:0];
	NSMutableSet * touchesLeft = [NSMutableSet setWithSet:touches];
	/*
	for(SharedObject * curObject in currentlyManipulated)
	{
		[takenTouches unionSet:[curObject trackedTouches]];
	}
	 */
	for(SharedObject * curObject in allObjects)
	{
		if([touchesLeft count] == 0)
		{
			break;
		}
		NSMutableSet * curRelevantTouches = [curObject relevantTouches:touchesLeft];
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
				[self addManipulatedObject:curObject withTouches:allowableTouches];
				[takenTouches unionSet:allowableTouches];
				[touchesLeft minusSet:takenTouches];
			}
		}
	}
	
	if([takenTouches containsObject:startTouch])
	{
		self.startTouch = nil;
	}
	
	//NSMutableSet * touchesLeft = [NSMutableSet setWithSet:touches];
	//[touchesLeft minusSet:takenTouches];
	if([touchesLeft count] == 0)
	{
		self.startTouch = nil;
	}else if([touchesLeft count] == 1)
	{
		UITouch * theTouch = [touchesLeft anyObject];
		
		if(startTouch == nil)
		{
			self.startTouch = theTouch;
		}else if(![takenTouches containsObject:startTouch]){
			CGPoint startPoint = [startTouch locationInView:self.view];
			if(!CGPointEqualToPoint(startPoint, CGPointZero))
			{
				[self addLineForStartTouch:startTouch endTouch:theTouch];
			}else{
				self.startTouch = nil;
			}
		}else{
			self.startTouch = nil;
		}
	}else if([touchesLeft count] == 2)
	{
		NSMutableArray * orderedTouches = [NSMutableArray arrayWithCapacity:2];
		for(UITouch * curTouch in touchesLeft)
		{
			[orderedTouches addObject:curTouch];
		}
		UITouch * firstTouch = [orderedTouches objectAtIndex:0];
		UITouch * secondTouch = [orderedTouches objectAtIndex:1];
		
		[self addLineForStartTouch:firstTouch endTouch:secondTouch];
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