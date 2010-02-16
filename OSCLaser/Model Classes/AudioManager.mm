//
//  AudioManager.mm
//  OSCLaser
//
//  Created by Stanford Harmonics on 2/13/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "AudioManager.h"
#import "mopho.h"
#import "SharedCollection.h"
#import "MultiPointObject.h"
#import "ControlPoint.h"

static AudioManager * shared;





void audioCallback( Float32 * buffer, UInt32 numFrames, void * userData)
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	 NSMutableArray * multiPointObjects = [SharedCollection sharedCollection].sharedObjects;
	 @synchronized(multiPointObjects)
	{
		// read the clock
		int *t = (int*)userData;
		// zero out output buffer
		memset(buffer, 0, 2*numFrames*sizeof(SAMPLE));
		
		if([AudioManager sharedManager].mute) return;

		 for(MultiPointObject * curObject in multiPointObjects)
		 {
			 NSArray * controlPoints = [curObject getControlPoints];
			
			 for(int i = 0; i < [controlPoints count]; i++)
			 {
				  //scaledPosition is an (x,y) point with x,y in [0,1]
				 CGPoint scaledPosition = [curObject scaledPositionAtIndex:i];
				 if(i == 0)
				 {
					 [curObject.soundObject setForPointOne:scaledPosition];
				 }else if(i == 1)
				 {
					 [curObject.soundObject setForPointTwo:scaledPosition];
				 }else if(i == 2)
				 {
					 [curObject.soundObject setForPointThree:scaledPosition];
				 }else if(i == 3)
				 {
					 [curObject.soundObject setForPointFour:scaledPosition];
				 }
			 }
			 // determine sequencer status
			 int beats = [Sequencer sharedSequencer].beatsPerMeasure * [Sequencer sharedSequencer].numMeasures;
			 int beatIndex = [AudioManager sharedManager].beatTick % beats;
			 BOOL isOn = [[Sequencer sharedSequencer] object:curObject isOnAtIndex:beatIndex];
			
			 // scale gain for multiple objects
			 [curObject.soundObject setGainTargetScaledBy: [multiPointObjects count]];
			 
			 // synthesize
			 [curObject.soundObject synthesize:buffer of:numFrames that:isOn at:*t];
		
		 }
		// tick time counter
		*t += numFrames;
		// tick beat counter
		if(*t % [[AudioManager sharedManager] getSamplesPerBeat] < numFrames) [[AudioManager sharedManager] incBeatTick];
	}
	
	[pool release];
}


@implementation AudioManager
		   
@synthesize mute, t, tempo, beatTick;

+ (AudioManager*) sharedManager
{
	if(shared == nil)
	{
		shared = [[AudioManager alloc] init];
	}
	
	return shared;
}

+ (void) releaseShared
{
	[shared release];
}

- (id) init
{
	if(self = [super init])
	{
		// init audio
		// log 
		NSLog( @"starting real-time audio..." ); 
		
		// init the audio layer 
		bool result = MoAudio::init(MY_SRATE, FRAMESIZE, NUMCHANNELS); 
		if( !result ) 
		{ 
			// something went wrong 
			NSLog( @"cannot initialize real-time audio!" ); 
			// bail out 
			return self; 
		} 
		
		t = 0;
		mute = NO;
		tempo = 80;
		beatTick = 0;

		
	}
	
	return self;
}

- (void) startCallback
{
	
	// start the audio layer, registering a callback method 
	bool result = MoAudio::start(audioCallback, &t); 
	if( !result ) 
	{ 
		// something went wrong 
		NSLog( @"cannot start real-time audio!" ); 
		// bail out 
		return; 
	} 
}

- (void) muteOn
{
	mute = YES;
}

- (void) muteOff
{
	mute = NO;
}
			
- (void) incBeatTick
{
	beatTick++;
}

- (int) getSamplesPerBeat
{
	float bps = tempo / 60.0;
	float bps16th = bps * 4;
	return floor( MY_SRATE / bps16th );
}

@end
