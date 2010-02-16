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
			 [curObject.soundObject setGainTargetScaledBy: [multiPointObjects count]];
			 [curObject.soundObject synthesize:buffer of:numFrames];
		
		 }
		//[AudioManager scaleGainOf:buffer of:numFrames containing:[multiPointObjects count]];
		*t += numFrames;
	}
}


@implementation AudioManager
		   
@synthesize mute, t;

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

+ (void) scaleGainOf:(Float32 *)buffer of:(int)numFrames containing:(int)numObjects
{
	for(int i = 0; i < numFrames; i++)
	{
		buffer[2*i] /= numObjects;
		buffer[2*i+1] /= numObjects;
	}
}

@end
