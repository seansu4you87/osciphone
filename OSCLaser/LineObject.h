//
//  LineObject.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/1/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedObject.h"

@interface LineObject : SharedObject {
	CGPoint startPercentPoint;
	CGPoint endPercentPoint;
}

- (id) initOnView:(UIView*)parentView withStartPoint:(CGPoint)parentStart endPoint:(CGPoint) parentEnd;
- (void) updateAllValues;

@end
