//
//  SequencerRenderer.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SequencerRenderer.h"
#import "Sequencer.h"
#import "SharedUtility.h"
#import "MultiPointObject.h"
#import "GLSlider.h"
#import "AudioManager.h"

#define DECEL_RATE 0.03
#define ACCEL_RATE 0.11

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 480

#define PERCENT_WIDTH 0.95
#define PERCENT_HEIGHT 0.90
#define PERCENT_NAME 0.1
#define BEAT_PADDING 3
#define RECT_GRAIN 2

@implementation SequencerRenderer

- (void) initRectVertices
{
	rectVertices = (GLfloat*)malloc(2*4*sizeof(GLfloat));
	
	rectVertices[0] = 0;
	rectVertices[1] = 0;
	
	rectVertices[2] = 1;
	rectVertices[3] = 0;
	
	rectVertices[4] = 1;
	rectVertices[5] = 1;
	
	rectVertices[6] = 0;
	rectVertices[7] = 1;
}

- (void) initColorVertices
{
	colorVertices = (GLubyte*)malloc(4*4*sizeof(GLubyte));
	for(int i = 0; i < 4; i++)
	{
		colorVertices[4*i] = 50;
		colorVertices[4*i+1] = 50;
		colorVertices[4*i+2] = 50;
		colorVertices[4*i+3] = 50;
	}
	
	fullColorVertices = (GLubyte*)malloc(4*4*sizeof(GLubyte));
	for(int i = 0; i < 4; i++)
	{
		fullColorVertices[4*i] = 25;
		fullColorVertices[4*i+1] = 25;
		fullColorVertices[4*i+2] = 25;
		fullColorVertices[4*i+3] = 25;
	}
}

- (void) toggleFullColor:(UIColor*)curColor
{
	float red = 255*[SharedUtility getRedFromColor:curColor];
	float green = 255*[SharedUtility getGreenFromColor:curColor];
	float blue = 255*[SharedUtility getBlueFromColor:curColor];
	float alpha = 255*[SharedUtility getAlphaFromColor:curColor];
	
	for(int i = 0; i < 4; i++)
	{
		if(i != 2)
		{
			fullColorVertices[4*i] = red;
			fullColorVertices[4*i+1] = green;
			fullColorVertices[4*i+2] = blue;
			fullColorVertices[4*i+3] = alpha;
		}
	}
}

- (void) initCenteredRectColors
{
	int numVertices = 2 + 4*RECT_GRAIN;
	centeredRectColors = (GLubyte*)malloc(4*numVertices*sizeof(GLubyte));
	for(int i = 0; i < numVertices; i++)
	{
		centeredRectColors[4*i] = 25;
		centeredRectColors[4*i+1] = 25;
		centeredRectColors[4*i+2] = 25;
		centeredRectColors[4*i+3] = 25;
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

- (void) setRectColorFromValue:(float)theValue
{
	float minValue = 0.0;
	float maxValue = 0.85;
	float newValue = 255*(minValue + theValue*(maxValue - minValue));
	
	centeredRectColors[0] = newValue;
	centeredRectColors[1] = newValue;
	centeredRectColors[2] = newValue;
	centeredRectColors[3] = newValue;
}

- (id) init
{
	if(self = [super init])
	{
		columnFaders = [[NSMutableArray arrayWithCapacity:16] retain];
		[self initRectVertices];
		[self initColorVertices];
		[self initCenteredRectVertices];
		[self initCenteredRectColors];
	}
	
	return self;
}

- (id) initWithHeight:(float)theHeight andWidth:(float)theWidth
{
	if(self = [self init])
	{
		backingHeight = theHeight;
		backingWidth = theWidth;
	}
	
	return self;
}

- (void) setToggledColor:(UIColor*)curColor
{
	float red = 255*[SharedUtility getRedFromColor:curColor];
	float green = 255*[SharedUtility getGreenFromColor:curColor];
	float blue = 255*[SharedUtility getBlueFromColor:curColor];
	float alpha = 255*[SharedUtility getAlphaFromColor:curColor];
	
	colorVertices[0] = red;
	colorVertices[1] = green;
	colorVertices[2] = blue;
	colorVertices[3] = alpha;
}

- (void) setColorsOff
{
	colorVertices[0] = 100;
	colorVertices[1] = 100;
	colorVertices[2] = 100;
	colorVertices[3] = 100;
}

- (void) renderSequencer:(Sequencer*)sequencer
{
	NSArray * objects = [sequencer currentObjects];
	int nBeats = [sequencer numBeats];
	
	if([columnFaders count] != nBeats)
	{
		[columnFaders removeAllObjects];
		for(int i = 0; i < nBeats; i++)
		{
			[columnFaders addObject:[[[GLSlider alloc] initWithAccelRate:ACCEL_RATE decelRate:DECEL_RATE] autorelease]];
		}
	}
	
	glPushMatrix();
	//prepare for landscape drawing
	glTranslatef(backingWidth, 0.0, 0.0);
	glRotatef(90.0, 0.0, 0.0, 1.0);
	
	float totalWidth = backingHeight*PERCENT_WIDTH;
	float totalHeight = backingWidth*PERCENT_HEIGHT;
	float unpaddedBeatHeight = totalHeight/[objects count];
	float paddedBeatHeight = unpaddedBeatHeight - 2*BEAT_PADDING;
	float nameWidth = totalWidth*PERCENT_NAME;
	float beatsWidth = totalWidth*(1 - PERCENT_NAME);
	float unpaddedBeatWidth = beatsWidth/nBeats;
	float paddedBeatWidth = unpaddedBeatWidth - 2*BEAT_PADDING;
	
	float xStartCoord = backingHeight*(1.0 - PERCENT_WIDTH)/2.0;
	float yStartCoord = backingWidth*(1.0 - PERCENT_HEIGHT)/2.0;
	glTranslatef(xStartCoord, yStartCoord, 0.0);
	
	for(int i = 0; i < [objects count]; i++)
	{
		MultiPointObject * mObj = [objects objectAtIndex:i];
		float yCoord = i*unpaddedBeatHeight + BEAT_PADDING;
		[self toggleFullColor:mObj.baseColor];
		glPushMatrix();
		
		glTranslatef(0, yCoord, 0.0);
		glScalef(nameWidth, paddedBeatHeight, 1.0);
		glVertexPointer(2, GL_FLOAT, 0, rectVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, fullColorVertices);
		glEnableClientState(GL_COLOR_ARRAY);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		
		glPopMatrix();
	}
	
	glTranslatef(nameWidth, 0.0, 0.0);
	int currentBeat = [AudioManager sharedManager].beatTick%([sequencer numBeats]);
	for(int i = 0; i < nBeats; i++)
	{
		GLSlider * curSlider = [columnFaders objectAtIndex:i];
		if(currentBeat == i)
		{
			[curSlider increment];
		}else{
			[curSlider decrement];
		}
		
		[self setRectColorFromValue:curSlider.currentValue];
		float rectXCoord = (i+0.5)*unpaddedBeatWidth;
		glPushMatrix();
		glTranslatef(rectXCoord, totalHeight/2.0, 0.0);
		glScalef(unpaddedBeatWidth+2, backingWidth*1.1, 1.0);
		glVertexPointer(2, GL_FLOAT, 0, centeredRectVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, centeredRectColors);
		glEnableClientState(GL_COLOR_ARRAY);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 2+4*RECT_GRAIN);
		glPopMatrix();
		
		for(int j = 0; j < [objects count]; j++)
		{
			float xCoord = i*unpaddedBeatWidth + BEAT_PADDING;
			float yCoord = j*unpaddedBeatHeight + BEAT_PADDING;
			MultiPointObject * mObj = [objects objectAtIndex:j];
			if([sequencer object:mObj isOnAtIndex:i])
			{
				[self setToggledColor:mObj.baseColor];
			}else{
				[self setColorsOff];
			}
			
			glPushMatrix();
			
			glTranslatef(xCoord, yCoord, 0.0);
			glScalef(paddedBeatWidth, paddedBeatHeight, 1.0);
			glVertexPointer(2, GL_FLOAT, 0, rectVertices);
			glEnableClientState(GL_VERTEX_ARRAY);
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorVertices);
			glEnableClientState(GL_COLOR_ARRAY);
			glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
			
			glPopMatrix();
			 
		}
	}
	
	
	glPopMatrix();
}



+ (void) applyTouchPoint:(CGPoint)thePoint toSequencer:(Sequencer*)theSequencer
{
	NSArray * objects = [theSequencer currentObjects];
	int nBeats = [theSequencer numBeats];
	
	CGPoint transformed = CGPointMake(thePoint.y, SCREEN_WIDTH - thePoint.x);
	
	float totalWidth = SCREEN_HEIGHT*PERCENT_WIDTH;
	float totalHeight = SCREEN_WIDTH*PERCENT_HEIGHT;
	float unpaddedBeatHeight = totalHeight/[objects count];
	//float paddedBeatHeight = unpaddedBeatHeight - 2*BEAT_PADDING;
	float nameWidth = totalWidth*PERCENT_NAME;
	float beatsWidth = totalWidth*(1 - PERCENT_NAME);
	float unpaddedBeatWidth = beatsWidth/nBeats;
	//float paddedBeatWidth = unpaddedBeatWidth - 2*BEAT_PADDING;
	
	float xStartCoord = SCREEN_HEIGHT*(1.0 - PERCENT_WIDTH)/2.0;
	float yStartCoord = SCREEN_WIDTH*(1.0 - PERCENT_HEIGHT)/2.0;
	float xBeatStart = xStartCoord + nameWidth;
	
	CGRect sequenceRect = CGRectMake(xStartCoord, yStartCoord, totalWidth, totalHeight);
	if(!CGRectContainsPoint(sequenceRect, transformed))
	{
		return;
	}
	
	int objectIndex = (transformed.y - yStartCoord)/unpaddedBeatHeight;
	if(transformed.x < xBeatStart)
	{
		[theSequencer toggleObject:[objects objectAtIndex:objectIndex]];
		return;
	}
	
	int beatIndex = (transformed.x - xBeatStart)/unpaddedBeatWidth;
	[theSequencer toggleBeat:beatIndex forObject:[objects objectAtIndex:objectIndex]];
}

- (void) dealloc
{
	[columnFaders release];
	[super dealloc];
}

@end
