//
//  ObjectSettingsViewController.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ObjectSettingsViewController.h"
#import "MultiPointObject.h"
#import "ScaleNotePickerView.h"
#import "SharedUtility.h"
#import "SoundObject.h"
#import "NoteObject.h"

@implementation ObjectSettingsViewController

@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andObject:(MultiPointObject*)selectedObject
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        selected = selectedObject;
    }
    return self;
}

- (IBAction) scaleChanged
{
	
}

- (void) loadViewFromObject
{
	UIColor * darkColor = [SharedUtility darkerColorFromColor:selected.baseColor darkFactor:0.5];
	navBar.tintColor = darkColor;
	wavePicker.tintColor = darkColor;
	wavePicker.selectedSegmentIndex = selected.soundObject.modOsc;
	scalePicker.selectedSegmentIndex = selected.soundObject.scaleType;
	volumeSlider.value = selected.soundObject.gain;
	
	int num = [NoteObject numStepsForType:selected.soundObject.scaleType];
	NSMutableArray * notes = [NSMutableArray arrayWithCapacity:num];
	for(int i = 0; i < num; i++)
	{
		int curChromaticValue = [NoteObject convertToChromatic:i fromType:selected.soundObject.scaleType];
		NoteObject * curNote = [[NoteObject alloc] initWithScaleValue:curChromaticValue];
		curNote.isOn = [selected.soundObject containsNote:curChromaticValue];
		[notes addObject:[curNote autorelease]];
	}
	[notePicker setCurrentNotes:notes];
}

- (void) updateObjectFromView
{
	[selected.soundObject setModOsc:wavePicker.selectedSegmentIndex];
	[selected.soundObject setGain:volumeSlider.value];
	[selected.soundObject setScaleType:scalePicker.selectedSegmentIndex];
	//do notes too
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self loadViewFromObject];
    [super viewDidLoad];
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

- (IBAction) done
{
	[self updateObjectFromView];
	[delegate objectsSettingsViewControllerDidFinish:self];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
