//
//  ControlPoint.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ControlPoint.h"


@implementation ControlPoint

@synthesize controllingTouch;

- (id) init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) step
{
	
}

- (BOOL) beingTouched
{
	return controllingTouch != nil;
}

- (void) dealloc
{
	[controllingTouch release];
	[super dealloc];
}

@end
