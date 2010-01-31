//
//  OSCConfig.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "OSCConfig.h"

static OSCConfig * config;

@implementation OSCConfig

- (id) initFromPrefs
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) setPort:(int)thePort
{
	port = thePort;
	
	//write to file
}

- (void) setIP:(NSString*)theIP
{
	[ip release];
	ip = [theIP retain];
	
	//write to file
}

+ (OSCConfig*) sharedConfig
{
	if(config == nil)
	{
		config = [[OSCConfig alloc] initFromPrefs];
	}
	
	return config;
}

@end
