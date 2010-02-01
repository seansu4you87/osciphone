//
//  LineObject.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/1/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "LineObject.h"
#import "LineObjectView.h"
#import "SharedCollection.h"
#import "OSCConfig.h"
#import "OSCPort.h"

#define DEFAULT_RADIUS 20

@implementation LineObject

- (NSString *) objectName
{
	return @"LObject";
}

- (id) initOnView:(UIView*)parentView withStartPoint:(CGPoint)parentStart endPoint:(CGPoint) parentEnd
{
	if(self = [super init])
	{
		LineObjectView * theView = [LineObjectView lineViewOnParentView:parentView withParentStart:parentStart parentEnd:parentEnd radius:DEFAULT_RADIUS];
		objectView = [theView retain];
		[parentView addSubview:theView];
		
		startPercentPoint = CGPointMake(parentStart.x/parentView.frame.size.width, parentStart.y/parentView.frame.size.height);
		endPercentPoint = CGPointMake(parentEnd.x/parentView.frame.size.width, parentEnd.y/parentView.frame.size.height);
	}
	
	return self;
}

- (BOOL) touchesAreRelevant:(NSSet*)touches
{
	LineObjectView * myView = (LineObjectView*)objectView;
	return [myView touchesAreRelevant:touches];
}

- (void) updateAllValues
{
	NSString * address = [SharedCollection addressForObjectManip:self];
	address = [address stringByAppendingString:@"/set"];
	OSCPort * thePort = [OSCConfig sharedConfig].oscPort;
	[thePort sendTo:[address UTF8String] types:"iffff", self.objectID, startPercentPoint.x, startPercentPoint.y, endPercentPoint.x, endPercentPoint.y];
}

@end
