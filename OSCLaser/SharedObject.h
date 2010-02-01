//
//  SharedObject.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SharedObject : NSObject {
	int objectID;
}

+ (void) resetIDs;
+ (int) nextID;

- (NSString *) objectName;
- (void) updateAllValues;

@property(nonatomic, readonly) int objectID;

@end
