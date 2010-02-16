//
//  GLSlider.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GLSlider : NSObject {
	float currentValue;
	float accelRate;
	float decelRate;
}

@property(nonatomic, readonly) float currentValue;

- (id) initWithAccelRate:(float)accelerationRate decelRate:(float)decelerationRate;

- (void) increment;
- (void) decrement;
- (void) reset;

@end
