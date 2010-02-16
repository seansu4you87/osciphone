//
//  MultiObjectRenderer.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "MultiObjectRenderer.h"
#import "MultiPointObject.h"
#import "ControlPoint.h"
#import "SharedUtility.h"
#import "GLSlider.h"

#define NUM_CIRCLE_DIVISIONS 20
#define LINE_WIDTH 10.0
#define GRID_PADDING 4.0
#define RECT_GRAIN 2

#define BACKGROUND_ACCEL 0.050
#define BACKGROUND_DECEL 0.050

@implementation MultiObjectRenderer

#pragma mark vertex initializeres

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

- (void) initCenteredRectColors
{
	int numVertices = 2 + 4*RECT_GRAIN;
	centeredRectColors = (GLubyte*)malloc(4*numVertices*sizeof(GLubyte));
	for(int i = 0; i < numVertices; i++)
	{
		centeredRectColors[4*i] = 0;
		centeredRectColors[4*i+1] = 0;
		centeredRectColors[4*i+2] = 0;
		centeredRectColors[4*i+3] = 0;
	}
}

- (void) initCenteredRectVertices
{
	centeredRectVertices = (GLfloat*)malloc(2*(2+4*RECT_GRAIN)*sizeof(GLfloat));
	
	int currentIndex = 0;
	centeredRectVertices[currentIndex] = 0;
	centeredRectVertices[currentIndex+1] = 0;
	currentIndex += 2;
	
	float xValue, yValue;
	float step = 1.0/RECT_GRAIN;
	
	//top (left to right)
	yValue = -0.5;
	for(int i = 0; i <= RECT_GRAIN; i++)
	{
		centeredRectVertices[currentIndex] = -0.5 + i*step;
		centeredRectVertices[currentIndex+1] = yValue;
		currentIndex += 2;
	}
	
	//right (top to bottom)
	xValue = 0.5;
	for(int i = 1; i <= RECT_GRAIN; i++)
	{
		centeredRectVertices[currentIndex] = xValue;
		centeredRectVertices[currentIndex+1] = -0.5 + i*step;
		currentIndex += 2;
	}
	
	//bottom (right to left)
	yValue = 0.5;
	for(int i = 1; i <= RECT_GRAIN; i++)
	{
		centeredRectVertices[currentIndex] = 0.5 - i*step;
		centeredRectVertices[currentIndex+1] = yValue;
		currentIndex += 2;
	}
	
	//left (bottom to top)
	xValue = -0.5;
	for(int i = 1; i <= RECT_GRAIN; i++)
	{
		centeredRectVertices[currentIndex] = xValue;
		centeredRectVertices[currentIndex+1] = 0.5 - i*step;
		currentIndex += 2;
	}
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

#pragma mark guts

- (id) initWithHeight:(float)theHeight andWidth:(float)theWidth
{
	if(self = [super init])
	{
		ticker = 0.0;
		quantizedFaders = [[NSMutableArray arrayWithCapacity:5] retain];
		backingHeight = theHeight;
		backingWidth = theWidth;
		
		[self initCircleVertices];
		[self initRectVertices];
		[self initColorVertices];
		
		[self initCenteredRectVertices];
		[self initCenteredRectColors];
	}
	
	return self;
}

- (void) adjustForNumQuantizations:(int)numQuantizations
{
	if(numQuantizations > [quantizedFaders count])
	{
		int needed = numQuantizations - [quantizedFaders count];
		for(int i = 0; i < needed; i++)
		{
			[quantizedFaders addObject:[[[GLSlider alloc] initWithAccelRate:BACKGROUND_ACCEL decelRate:BACKGROUND_DECEL] autorelease]];
		}
	}else if(numQuantizations < [quantizedFaders count])
	 {
		 int toRemove = [quantizedFaders count] - numQuantizations;
		 for(int i = 0; i < toRemove; i++)
		 {
			 [quantizedFaders removeObjectAtIndex:[quantizedFaders count] - 1];
		 }
	 }else{
	 }
}
			 
 - (void) setRectColorFromValue:(float)theValue
 {
	 float minValue = 0.0;
	 float maxValue = 0.55;
	 float newValue = 255*(minValue + theValue*(maxValue - minValue));
	 
	 centeredRectColors[0] = newValue;
	 centeredRectColors[1] = newValue;
	 centeredRectColors[2] = newValue;
	 centeredRectColors[3] = newValue;
 }

- (void) renderMultiPointObjects:(NSArray*)multiObjects
{
	if([multiObjects count] > 0)
	{
		MultiPointObject * potentiallySelected = [multiObjects objectAtIndex:[multiObjects count] - 1];
		int numQuantizations = [potentiallySelected.soundObject numQuantizations];
		if(numQuantizations > 1)
		{
			float step = 1.0/numQuantizations;
			CGPoint scaledPoint = [potentiallySelected scaledPositionAtIndex:0];
			float width = backingWidth - 2*GRID_PADDING;
			float unpaddedHeight = backingHeight/(1.0*numQuantizations);
			float height =  unpaddedHeight - GRID_PADDING;
			float xCoord = backingWidth/2.0;
			
			[self adjustForNumQuantizations:numQuantizations];
			
			for(int i = 0; i < numQuantizations; i++)
			{
				GLSlider * curSlider = [quantizedFaders objectAtIndex:i];
				float yCoord = (i+0.5)*unpaddedHeight;
				glPushMatrix();
				glTranslatef(xCoord, yCoord, 0.0);
				glScalef(width, height, 1.0);
				
				if(scaledPoint.y >= i*step && scaledPoint.y < (i+1)*step && potentiallySelected.selected)
				{
					[curSlider increment];
				}else{
					[curSlider decrement];
				}
				
				[self setRectColorFromValue:curSlider.currentValue];
				
				glVertexPointer(2, GL_FLOAT, 0, centeredRectVertices);
				glEnableClientState(GL_VERTEX_ARRAY);
				glColorPointer(4, GL_UNSIGNED_BYTE, 0, centeredRectColors);
				glEnableClientState(GL_COLOR_ARRAY);
				glDrawArrays(GL_TRIANGLE_FAN, 0, 2+4*RECT_GRAIN);
				 glPopMatrix();
			}
		}
	}
	
	ticker += 0.075;
	float negHalfToHalf = cos(ticker)/2.0;
    
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
			if(!([controlPoints count] == 1 || ([controlPoints count] == 2 && i == 1)))
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
}

- (void) dealloc
{
	[quantizedFaders release];
	free(circleVertices);
	free(rectVertices);
	free(colorVertices);
	
	free(centeredRectVertices);
	free(centeredRectColors);
	
	[super dealloc];
}

@end
