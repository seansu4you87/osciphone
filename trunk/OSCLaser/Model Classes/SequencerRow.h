//
//  SequencerRow.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SequencerRow : NSObject {
	NSMutableArray * toggles;
}

- (id) initWithLength:(int)length;

- (BOOL) onAtIndex:(int)index;
- (void) toggleAtIndex:(int)index;

@end
