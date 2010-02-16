//
//  MultiObjectRenderer.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface MultiObjectRenderer : NSObject {
	float ticker;
	float backingHeight;
	float backingWidth;
	
	NSMutableArray * quantizedFaders;
	
	GLfloat * circleVertices;
	GLfloat * rectVertices;
	GLubyte * colorVertices;
	
	GLfloat * centeredRectVertices;
	GLubyte * centeredRectColors;
}

- (id) initWithHeight:(float)theHeight andWidth:(float)theWidth;
- (void) renderMultiPointObjects:(NSArray*)multiObjects;
- (void) adjustForNumQuantizations:(int)numQuantizations;

@end
