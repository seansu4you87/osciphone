//
//  NoteObject.h
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoteObject : NSObject {
	
	int note;

}

@property(nonatomic, readonly) int note;

- (id) initWithScaleValue:(int)scaleValue;

- (int) majorToChromatic:(int)scaleValue;
- (int) minorToChromatic:(int)scaleValue;
- (int) pentatonicToChromatic:(int)scaleValue;

@end
