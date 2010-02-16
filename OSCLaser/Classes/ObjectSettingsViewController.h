//
//  ObjectSettingsViewController.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ObjectSettingsViewControllerDelegate;

@class MultiPointObject, ScaleNotePickerView;

@interface ObjectSettingsViewController : UIViewController {
	id <ObjectSettingsViewControllerDelegate> delegate;
	IBOutlet UINavigationBar * navBar;
	IBOutlet UISegmentedControl * wavePicker;
	IBOutlet UISegmentedControl * scalePicker;
	IBOutlet UISlider * volumeSlider;
	IBOutlet ScaleNotePickerView * notePicker;
	MultiPointObject * selected;
}

@property (nonatomic, assign) id <ObjectSettingsViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andObject:(MultiPointObject*)selectedObject; 
- (IBAction)done;
- (IBAction)scaleChanged;

@end

@protocol ObjectSettingsViewControllerDelegate
- (void)objectsSettingsViewDidLoad:(ObjectSettingsViewController *)controller;
- (void)objectsSettingsViewControllerDidFinish:(ObjectSettingsViewController *)controller;
@end


