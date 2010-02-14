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

#define SRATE 24000
#define FRAMESIZE 256
#define NUMCHANNELS 2


void audioCallback( Float32 * buffer, UInt32 numFrames, void * userData)
{
	 NSMutableArray * multiPointObjects = [SharedCollection sharedCollection].sharedObjects;
	 
	 for(MultiPointObject * curObject in multiPointObjects)
	 {
		 NSArray * controlPoints = [curObject getControlPoints];
		 for(int i = 0; i < [controlPoints count]; i++)
		 {
			  //scaledPosition is an (x,y) point with x,y in [0,1]
			 CGPoint scaledPosition = [curObject scaledPositionAtIndex:i];
		 }
	 }
	 
}


@implementation AudioManager

- (id) init
{
	if(self = [super init])
	{
		// init audio
		// log 
		NSLog( @"starting real-time audio..." ); 
		
		// init the audio layer 
		bool result = MoAudio::init(SRATE, FRAMESIZE, NUMCHANNELS); 
		if( !result ) 
		{ 
			// something went wrong 
			NSLog( @"cannot initialize real-time audio!" ); 
			// bail out 
			return self; 
		} 

		
	}
	
	return self;
}

- (void) startCallback
{
	
	// start the audio layer, registering a callback method 
	bool result = MoAudio::start(audioCallback, NULL); 
	if( !result ) 
	{ 
		// something went wrong 
		NSLog( @"cannot start real-time audio!" ); 
		// bail out 
		return; 
	} 
}

@end
