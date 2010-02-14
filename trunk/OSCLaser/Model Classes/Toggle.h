//
//  Toggle.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Toggle : NSObject {
	BOOL on;
}

- (void) toggle;
- (BOOL) isOn;

@end
