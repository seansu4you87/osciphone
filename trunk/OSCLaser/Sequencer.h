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


@interface Sequencer : NSObject {
	id<SequencerDelegate> delegate;
	int beatsPerMeasure;
	int numMeasures;
	NSMutableDictionary * state;
}

@property(nonatomic, retain) id<SequencerDelegate> delegate;

- (id) initWithDelegate:(id<SequencerDelegate>)theDelegate measures:(int)nMeasures BPM:(int)bpm;
- (int) numBeats;

@end
