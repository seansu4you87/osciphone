//
//  NoteObject.h
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	MAJOR = 0, MINOR = 1, CHROMATIC = 2, PENTATONIC=3
};

@interface NoteObject : NSObject {
	BOOL isOn;
	int note;
}

@property(nonatomic, readonly) int note;
@property(nonatomic) BOOL isOn;

- (id) initWithScaleValue:(int)scaleValue;
- (void) toggle;

+ (int) convertToChromatic:(int)scaleValue fromType:(int)scaleType;

+ (int) majorToChromatic:(int)scaleValue;
+ (int) minorToChromatic:(int)scaleValue;
+ (int) pentatonicToChromatic:(int)scaleValue;

+ (int) chromaticToPentatonic:(int)scaleValue;
+ (int) chromaticToMajor:(int)scaleValue;
+ (int) chromaticToMinor:(int)scaleValue;

+ (int)numStepsForType:(int)scaleType;

+ (BOOL) array:(NSArray*)noteArray containsValue:(int)scaleValue;

@end
