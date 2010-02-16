//
//  ScaleNotePickerView.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/16/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScaleNotePickerView : UIView {
	NSMutableArray * notes;
	BOOL random;
}

@property(nonatomic, readonly) NSMutableArray * notes;

- (void) setCurrentNotes:(NSMutableArray*)newNotes;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
