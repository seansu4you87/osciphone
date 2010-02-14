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
#define LINE_WIDTH 10.0
#define GRID_PADDING 4.0

static double timer = 0.0;

- (void) initCircleVertices
{
	circleVertices = (GLfloat*)malloc(2*(NUM_CIRCLE_DIVISIONS + 2)*sizeof(GLfloat));
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
	rectVertices = (GLfloat*)malloc(2*4*sizeof(GLfloat));
	
	rectVertices[0] = 0;
	rectVertices[1] = -0.5;
	
	rectVertices[2] = 0;
	rectVertices[3] = 0.5;
	
	rectVertices[4] = 1.0;
	rectVertices[5] = 0.5;
	
	rectVertices[6] = 1.0;
	rectVertices[7] = -0.5;
}

- (void) initColorVertices
{
	colorVertices = (GLubyte*)malloc(4*(NUM_CIRCLE_DIVISIONS + 2)*sizeof(GLubyte));
	
	for(int i = 0; i < NUM_CIRCLE_DIVISIONS + 2; i++)
	{
		colorVertices[4*i] = 0;
		colorVertices[4*i+1] = 0;
		colorVertices[4*i+2] = 0;
		colorVertices[4*i+3] = 0;
	}
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
		[self initColorVertices];
	}
	
	return self;
}

- (void) renderMultiPoints:(NSArray*)multiObjects
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
	
    //glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	if([multiObjects count] > 0)
	{
		MultiPointObject * potentiallySelected = [multiObjects objectAtIndex:[multiObjects count] - 1];
		int numQuantizations = [potentiallySelected.soundObject numQuantizations];
		if(potentiallySelected.selected && numQuantizations> 1)
		{
			float step = 1.0/numQuantizations;
			CGPoint scaledPoint = [potentiallySelected scaledPositionAtIndex:0];
			float width = backingWidth - 2*GRID_PADDING;
			float unpaddedHeight = backingHeight/(1.0*numQuantizations);
			float height =  unpaddedHeight - GRID_PADDING;
			float xCoord = GRID_PADDING;
			for(int i = 0; i < numQuantizations; i++)
			{
				float yCoord = (i+0.5)*unpaddedHeight;
				glPushMatrix();
				glTranslatef(xCoord, yCoord, 0.0);
				glScalef(width, height, 1.0);
				
				if(scaledPoint.y >= i*step && scaledPoint.y < (i+1)*step)
				{
					glVertexPointer(2, GL_FLOAT, 0, rectVertices);
					glEnableClientState(GL_VERTEX_ARRAY);
					glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorVertices);
					glEnableClientState(GL_COLOR_ARRAY);
					glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
				}else{
				}
				glPopMatrix();
			}
			
		}
	}
	
	timer += 0.075;
	float negHalfToHalf = cos(timer)/2.0;
    
	for(int j = 0; j< [multiObjects count]; j++)
	{
		MultiPointObject * object = [multiObjects objectAtIndex:j];
		NSArray * controlPoints = [object getControlPoints];
		float zCoord = 0.0;
		UIColor * curColor = object.currentColor;
		float red = 255*[SharedUtility getRedFromColor:curColor];
		float green = 255*[SharedUtility getGreenFromColor:curColor];
		float blue = 255*[SharedUtility getBlueFromColor:curColor];
		float alpha = 255*[SharedUtility getAlphaFromColor:curColor];
		if(object.selected)
		{
			float boost = (negHalfToHalf + 0.5)*175;
			red += boost;
			green += boost;
			blue += boost;
			red = MIN(red, 255);
			blue = MIN(blue, 255);
			green = MIN(green, 255);
		}
		colorVertices[0] = red;
		colorVertices[1] = green;
		colorVertices[2] = blue;
		colorVertices[3] = alpha;

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
			if(!([controlPoints count] == 1 || ([controlPoints count] ==2 && i == 1)))
			{
				//rotate to face nextPoint
				glPushMatrix();
				glTranslatef(current.position.x, current.position.y, zCoord);
				CGPoint vector = [SharedUtility point:next.position minusPoint:current.position];
				float length = [SharedUtility magnitudeOf:vector];
				float zValue = 1.0;
				if(next.position.y < current.position.y)
				{
					zValue *= -1;
				}
				glRotatef([SharedUtility degreeAngleBetweenVector:CGPointMake(1.0, 0) andVector:vector], 0.0, 0.0, zValue);
				float scaleWidth = LINE_WIDTH;
				if(object.selected)
				{
					scaleWidth += negHalfToHalf*2.0;
				}
				glScalef(length, scaleWidth, 1.0);
				glVertexPointer(2, GL_FLOAT, 0, rectVertices);
				glEnableClientState(GL_VERTEX_ARRAY);
				glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorVertices);
				glEnableClientState(GL_COLOR_ARRAY);
				glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
				glPopMatrix();
			}
		}
		
		for(int i = 0; i < [controlPoints count]; i++)
		{
			ControlPoint * current = [controlPoints objectAtIndex:i];
			glPushMatrix();
			glTranslatef(current.position.x, current.position.y, zCoord);
			float scaleRadius = current.radius;
			if(object.selected)
			{
				scaleRadius += negHalfToHalf*5.0;
			}
			glScalef(scaleRadius, scaleRadius, 1.0);
			glVertexPointer(2, GL_FLOAT, 0, circleVertices);
			glEnableClientState(GL_VERTEX_ARRAY);
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorVertices);
			glEnableClientState(GL_COLOR_ARRAY);
			glDrawArrays(GL_TRIANGLE_FAN, 0, NUM_CIRCLE_DIVISIONS+2);
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
