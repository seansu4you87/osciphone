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

	 SharedCollection * theCollection = [SharedCollection sharedCollection];
	 NSMutableArray * multiPointObjects = theCollection.sharedObjects;
	 for(int i = 0; i < [multiPointObjects count]; i++)
	 {
		 MultiPointObject * curObject = [multiPointObjects objectAtIndex:i];
	 }
	 
	 for(MultiPointObject * curObject in multiPointObjects)
	 {
		 NSArray * controlPoints = [curObject getControlPoints];
		 for(int i = 0; i < [controlPoints count]; i++)
		 {
			 ControlPoint * curPoint = [controlPoints objectAtIndex:i];
			 CGPoint scaledPosition = [curObject scaleXYPoint:curPoint.position];
			 //scaledPosition is an (x,y) point with x,y in [0,1]
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
		bool result = MoAudio::init( SRATE, FRAMESIZE, NUMCHANNELS ); 
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
	bool result = MoAudio::start( audioCallback, NULL ); 
	if( !result ) 
	{ 
		// something went wrong 
		NSLog( @"cannot start real-time audio!" ); 
		// bail out 
		return; 
	} 
}

@end
