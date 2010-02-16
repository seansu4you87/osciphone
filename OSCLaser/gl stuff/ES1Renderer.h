//
//  ES1Renderer.h
//  gl_test
//
//  Created by Ben Cunningham on 2/11/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "EAGLView.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class MultiObjectRenderer, SequencerRenderer;

@interface ES1Renderer : NSObject
{
@private
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
	MultiObjectRenderer * mObjRenderer;
	BOOL isRenderingPoints;
	float pointsOffset;
	
	SequencerRenderer * sequenceRenderer;
	BOOL isRenderingSequencer;
	float sequenceOffset;
	
	BOOL movingToSequencer;
	BOOL movingToPoints;
	int stepsLeft;
	float step;
}

- (void) renderEverything;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

- (void) switchToSequencer;
- (void) switchToPoints;
- (BOOL) isMoving;

@end
