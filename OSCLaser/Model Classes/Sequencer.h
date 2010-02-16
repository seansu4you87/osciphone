//
//  Sequencer.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SequencerDelegate

- (NSArray*)objects;

@end

@class MultiPointObject;

@interface Sequencer : NSObject {
	id<SequencerDelegate> delegate;
	int beatsPerMeasure;
	int numMeasures;
	NSMutableDictionary * state;
}

@property(nonatomic, retain) id<SequencerDelegate> delegate;
@property(nonatomic, readonly) int beatsPerMeasure, numMeasures;
- (id) initWithDelegate:(id<SequencerDelegate>)theDelegate measures:(int)nMeasures BPM:(int)bpm;
- (int) numBeats;

+ (NSString*) keyForMultiPointObject:(MultiPointObject*)mObj;
+ (Sequencer*)sharedSequencer;
+ (void) releaseShared;
- (NSArray*) currentObjects;
- (BOOL) object:(id)obj isOnAtIndex:(int)beatIndex;
- (void) toggleObject:(id)obj;
- (void) toggleBeat:(int)beatIndex forObject:(id)obj;
- (void) refresh;

@end
