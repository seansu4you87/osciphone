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
		[parent touchesEnded:touches withEvent:event];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
	if(parent)
	{
		[parent touchesMoved:touches withEvent:event];
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(parent)
	{
		[parent touchesBegan:touches withEvent:event];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
