//
//  Toggle.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "Toggle.h"


@implementation Toggle

- (id) init
{
	if(self = [super init])
	{
		on = NO;
	}
	
	return self;
}

- (void) toggle
{
	on = !on;
}

- (BOOL) isOn
{
	return on;
}

@end
