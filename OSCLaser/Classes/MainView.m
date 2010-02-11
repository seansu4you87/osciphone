//
//  MainView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "MainView.h"
#import "MainViewController.h"
#import "OSCConfig.h"
#import "OSCPort.h"

#define USE_NEW YES

@implementation MainView

@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(parent)
	{
		if(USE_NEW)
		{
			[parent theTouchesEnded:touches withEvent:event];
		}else{
			[parent touchesEnded:touches withEvent:event];
		}
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
	if(parent)
	{
		if(USE_NEW)
		{
			[parent theTouchesMoved:touches withEvent:event];
		}else {
			[parent touchesMoved:touches withEvent:event];
		}
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(parent)
	{
		if(USE_NEW)
		{
			[parent theTouchesBegan:touches withEvent:event];
		}else{
			[parent touchesBegan:touches withEvent:event];
		}
	}
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
