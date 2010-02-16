//
//  GLSlider.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "GLSlider.h"

#define MAX_VALUE 1.0
#define MIN_VALUE 0.0

#define DEFAULT_ACCELERATION 0.075
#define DEFAULT_DECELERATION 0.100

@implementation GLSlider

@synthesize currentValue;

- (id) init
{
	if(self = [super init])
	{
		currentValue = 0.0;
		accelRate = DEFAULT_ACCELERATION;
		decelRate = DEFAULT_DECELERATION;
	}
	
	return self;
}

- (void) reset
{
	currentValue = 0.0;
}

- (id) initWithAccelRate:(float)accelerationRate decelRate:(float)decelerationRate
{
	if(self = [self init])
	{
		accelRate = accelerationRate;
		decelRate = decelerationRate;
	}
	
	return self;
}

- (void) increment
{
	currentValue = MIN(MAX_VALUE, currentValue + accelRate);
}

- (void) decrement
{
	currentValue = MAX(MIN_VALUE, currentValue - decelRate);
}



@end
