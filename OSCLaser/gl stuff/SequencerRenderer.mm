//
//  SequencerRenderer.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "SequencerRenderer.h"
#import "Sequencer.h"

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 460

#define PERCENT_WIDTH 0.95
#define PERCENT_HEIGHT 0.90
#define PERCENT_NAME 0.075
#define BEAT_PADDING 2

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
}

- (id) init
{
	if(self = [super init])
	{
		columnFaders = [[NSMutableArray arrayWithCapacity:16] retain];
		[self initRectVertices];
		[self initColorVertices];
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

- (void) setColorsOn
{
	colorVertices[0] = 255;
	colorVertices[1] = 0;
	colorVertices[2] = 0;
	colorVertices[3] = 0;
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
		//draw names
	}
	
	glTranslatef(nameWidth, 0.0, 0.0);
	
	for(int i = 0; i < nBeats; i++)
	{
		for(int j = 0; j < [objects count]; j++)
		{
			float xCoord = i*unpaddedBeatWidth + BEAT_PADDING;
			float yCoord = j*unpaddedBeatHeight + BEAT_PADDING;
			
			if([sequencer object:[objects objectAtIndex:j] isOnAtIndex:i])
			{
				[self setColorsOn];
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
