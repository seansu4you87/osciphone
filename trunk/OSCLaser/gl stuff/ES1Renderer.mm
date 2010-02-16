//
//  ES1Renderer.m
//  gl_test
//
//  Created by Ben Cunningham on 2/11/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "ES1Renderer.h"
#import "MultiPointObject.h"
#import "ControlPoint.h"
#import "SharedCollection.h"
#import "MultiObjectRenderer.h"
#import "SequencerRenderer.h"
#import "SharedUtility.h"
#import "Sequencer.h"

@implementation ES1Renderer

// Create an ES 1.1 context
- (id) init
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context])
		{
            [self release];
            return nil;
        }
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffersOES(1, &defaultFramebuffer);
		glGenRenderbuffersOES(1, &colorRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
		
		isRenderingPoints = YES;
		isRenderingSequencer = NO;
	}
	
	return self;
}

- (void) glSetup
{
	// This application only creates a single context which is already set current at this point.
	// This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
	// This application only creates a single default framebuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(-1.0, 1.0, 0);
	glScalef(2.0/backingWidth, -2.0/backingHeight, 1.0);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	if(mObjRenderer == nil)
	{
		mObjRenderer = [[MultiObjectRenderer alloc] initWithHeight:backingHeight andWidth:backingWidth];
		pointsOffset = 0;
	}
	
	if(sequenceRenderer == nil)
	{
		sequenceRenderer = [[SequencerRenderer alloc] initWithHeight:backingHeight andWidth:backingWidth];
		sequenceOffset = -backingWidth;
	}
}

- (void) glSetdown
{
	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) translateValue:(float)translation
{
	pointsOffset += translation;
	sequenceOffset += translation;
}

- (BOOL) isMoving
{
	return isRenderingPoints && isRenderingSequencer;
}

- (void) renderEverything
{
	[self glSetup];
	
	if(movingToSequencer || movingToPoints)
	{
		[self translateValue:step];
		stepsLeft--;
		BOOL done = (stepsLeft == 0);
		if(done)
		{
			if(movingToPoints)
			{
				isRenderingSequencer = NO;
				movingToPoints = NO;
			}else{
				isRenderingPoints = NO;
				movingToSequencer = NO;
			}
		}
	}
	
	if(isRenderingPoints)
	{
		glPushMatrix();
		glTranslatef(pointsOffset, 0.0, 0.0);
		[mObjRenderer renderMultiPointObjects:[SharedCollection sharedCollection].sharedObjects];
		glPopMatrix();
	}
	
	if(isRenderingSequencer)
	{
		glPushMatrix();
		glTranslatef(sequenceOffset, 0.0, 0.0);
		[sequenceRenderer renderSequencer:[Sequencer sharedSequencer]];
		glPopMatrix();
	}
    
	[self glSetdown];
}

- (void) switchToSequencer
{
	isRenderingSequencer = YES;
	movingToSequencer = YES;
	stepsLeft = 30;
	step = (1.0*backingWidth)/stepsLeft;
}

- (void) switchToPoints
{
	isRenderingPoints = YES;
	movingToPoints = YES;
	stepsLeft = 30;
	step = (0.0 - backingWidth)/stepsLeft;
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{	
	// Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void) dealloc
{
	// Tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}

	if (colorRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	// Tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[mObjRenderer release];
	[sequenceRenderer release];
	
	[super dealloc];
}

@end
