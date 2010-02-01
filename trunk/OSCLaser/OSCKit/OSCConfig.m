//
//  OSCConfig.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "OSCConfig.h"
#import "OSCPort.h"

#define OUT_PORT_KEY @"preferredOutPort"
#define IP_KEY @"preferredIP"

static OSCConfig * config;

@implementation OSCConfig

@synthesize ip, port, oscPort;

- (id) initFromPrefs
{
	if(self = [super init])
	{
		ip = nil;
		port = 0;
		
		CFPropertyListRef outPortPref =  CFPreferencesCopyAppValue((CFStringRef)OUT_PORT_KEY, kCFPreferencesCurrentApplication);
		if(outPortPref)
		{
			CFNumberRef theNumber = (CFNumberRef) outPortPref;
			CFNumberGetValue(theNumber, kCFNumberIntType, &port);
			CFRelease(outPortPref);
		}
		
		CFPropertyListRef ipPref = CFPreferencesCopyAppValue((CFStringRef)IP_KEY, kCFPreferencesCurrentApplication);
		if(ipPref)
		{
			CFStringRef theIP = (CFStringRef) ipPref;
			NSString * casted = (NSString*)theIP;
			ip = [casted retain];
			CFRelease(ipPref);
		}
		
		[self updateOSCPort];
	}
	
	return self;
}

- (void) updateOSCPort
{
	if([self isConfigured])
	{
		[oscPort release];
		oscPort = [[OSCPort oscPortToAddress:[ip UTF8String] portNumber:port] retain];
	}
}

- (BOOL) ipIsConfigured
{
	return [ip length] > 0;
}

- (BOOL) portIsConfigured
{
	return port > 0;
}

- (BOOL) isConfigured
{
	return [self ipIsConfigured] && [self portIsConfigured];
}

- (void) setPort:(int)thePort
{
	if(thePort != port)
	{
		port = thePort;
		
		CFPreferencesSetAppValue((CFStringRef)OUT_PORT_KEY, CFNumberCreate(NULL, kCFNumberIntType, &port), kCFPreferencesCurrentApplication);
		CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
		
		[self updateOSCPort];
	}
}

- (void) setIP:(NSString*)theIP
{
	if(![theIP isEqualToString:ip])
	{
		[ip release];
		ip = [theIP retain];
		const char * cString = [ip UTF8String];
		CFStringRef cStr = CFStringCreateWithCString(NULL, cString, kCFStringEncodingUTF8);
		CFPreferencesSetAppValue((CFStringRef)IP_KEY, cStr, kCFPreferencesCurrentApplication);
		CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
		
		[self updateOSCPort];
	}
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
