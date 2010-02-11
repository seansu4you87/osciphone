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
#import "SharedUtility.h"

@implementation ES1Renderer

#define NUM_CIRCLE_DIVISIONS 20

- (void) initCircleVertices
{
	circleVertices = malloc(2*(NUM_CIRCLE_DIVISIONS + 2)*sizeof(GLfloat));
	circleVertices[0] = 0.0;
	circleVertices[1] = 0.0;
	
	float theta = 0;
	float thetaStep = 2.0*[SharedUtility PI]/NUM_CIRCLE_DIVISIONS;
	
	for(int i = 1; i < NUM_CIRCLE_DIVISIONS + 2; i++)
	{
		circleVertices[2*i] = cos(theta);
		circleVertices[2*i+1] = sin(theta);
		theta += thetaStep;
	}
}

- (void) initRectVertices
{
	rectVertices = malloc(2*4*sizeof(GLfloat));
}

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
		
		[self initCircleVertices];
		[self initRectVertices];
	}
	
	return self;
}

- (void) renderMultiPoints:(NSArray*)multiObjects
{
    // Replace the implementation of this method to do your own custom drawing
	
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };

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
	
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
	for(MultiPointObject * object in multiObjects)
	{
		NSArray * controlPoints = [object getControlPoints];
		for(int i = 0; i < [controlPoints count]; i++)
		{
			ControlPoint * current = [controlPoints objectAtIndex:i];
			ControlPoint * next;
			if(i == [controlPoints count] - 1)
			{
				next = [controlPoints objectAtIndex:0];
			}else{
				next = [controlPoints objectAtIndex:i+1];
			}
			glPushMatrix();
			glTranslatef(current.position.x, current.position.y, 0);
			glScalef(current.radius, current.radius, 1.0);
			
			glVertexPointer(2, GL_FLOAT, 0, circleVertices);
			glEnableClientState(GL_VERTEX_ARRAY);
			/*
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
			glEnableClientState(GL_COLOR_ARRAY);
			 */
			glDrawArrays(GL_TRIANGLE_FAN, 0, NUM_CIRCLE_DIVISIONS+2);
			
			//rotate to face nextPoint
			//draw line using rect vertices
			glPopMatrix();
		}
	}
    
	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
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
	
	free(circleVertices);
	free(rectVertices);
	
	[super dealloc];
}

@end
