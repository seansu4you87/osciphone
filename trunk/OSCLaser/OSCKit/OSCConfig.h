//
//  OSCConfig.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OSCConfig : NSObject {
	int port;
	NSString * ip;
}

- (id) initFromPrefs;

- (void) setPort:(int)thePort;
- (void) setIP:(NSString*)theIP;

+ (OSCConfig*) sharedConfig;

@property(nonatomic, readonly) int port;
@property(nonatomic, readonly) NSString * ip;

@end
