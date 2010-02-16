//
//  SequencerRenderer.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class Sequencer;

@interface SequencerRenderer : NSObject {
	float backingHeight;
	float backingWidth;
	NSMutableArray * columnFaders;
	
	GLfloat * rectVertices;
	GLubyte * colorVertices;
	GLubyte * fullColorVertices;
}

- (id) initWithHeight:(float)theHeight andWidth:(float)theWidth;
- (void) renderSequencer:(Sequencer*)sequencer;

+ (void) applyTouchPoint:(CGPoint)thePoint toSequencer:(Sequencer*)theSequencer;

@end
