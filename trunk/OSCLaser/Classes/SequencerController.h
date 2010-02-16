//
//  SequencerController.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SequencerController : NSObject {
	UIView * parentView;
}

- (id) initWithParentView:(UIView*)theParentView;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;


@end
