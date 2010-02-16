//
//  SequencerController.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SequencerController.h"
#import "SequencerRenderer.h"
#import "Sequencer.h"

@implementation SequencerController

- (id) initWithParentView:(UIView*)theParentView
{
	if(self = [super init])
	{
		parentView = theParentView;
	}
	
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch * touch in touches)
	{
		CGPoint touchPoint = [touch locationInView:parentView];
		[SequencerRenderer applyTouchPoint:touchPoint toSequencer:[Sequencer sharedSequencer]];
	}
}

@end
