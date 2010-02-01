//
//  MainView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "MainView.h"
#import "OSCConfig.h"
#import "OSCPort.h"

@implementation MainView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
	
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	
	if([touches count] == 1)
	{
		UITouch * theTouch = [touches anyObject];
		CGPoint viewCoord = [theTouch locationInView:self];
		float xPercent = viewCoord.x/self.frame.size.width;
		float yPercent = viewCoord.y/self.frame.size.height;
		[thePort sendTo:[[NSString stringWithFormat:@"/begin1"]UTF8String] types:"ff", xPercent, yPercent];
	}
	
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
