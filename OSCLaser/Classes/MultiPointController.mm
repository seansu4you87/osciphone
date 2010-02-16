//
//  MultiPointController.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "MultiPointController.h"
#import "MultiPointObject.h"
#import "SharedCollection.h"
#import "SharedObject.h"
#import "MainViewController.h"

//seconds it takes a touch to become an object
#define TOUCH_TIME 0.55
#define TAPS_TO_DELETE 3

@implementation MultiPointController

@synthesize startTouch, selected, touchTimer, mainView;

#pragma mark init

- (id) initWithParentView:(UIView*)theParentView
{
	if(self = [super init])
	{
		parentView = theParentView;
		
		currentlyManipulated = [[NSMutableSet setWithCapacity:0] retain];
		downTouches = [[NSMutableSet setWithCapacity:0] retain];
		
		colorIndex = 0;
	}
	
	return self;
}

#pragma mark misc

- (void) setSelected:(SharedObject*)theObject
{
	[selected updateUnselected];
	[selected release];
	selected = [theObject retain];
	[theObject updateSelected];
	
	if(theObject != nil)
	{
		NSMutableArray * objects = [SharedCollection sharedCollection].sharedObjects;
		@synchronized(objects)
		{
			[objects exchangeObjectAtIndex:[objects indexOfObject:theObject] withObjectAtIndex:[objects count] - 1];
		}
		[mainView allowInfo];
	}else{
		[mainView refuseInfo];
	}
}


- (void) removeObject:(SharedObject*)theObject
{
	if([currentlyManipulated containsObject:theObject])
	{
		[currentlyManipulated removeObject:theObject];
	}
	[[SharedCollection sharedCollection] removeSharedObject:theObject];
	
	if(theObject == selected)
	{
		self.selected = nil;
	}
	
	[[Sequencer sharedSequencer] refresh];
	if([[[SharedCollection sharedCollection] objects] count] == 0)
	{
		[mainView refuseSwitch];
	}
}

- (void) removeSelectedObject
{
	if(selected != nil)
	{
		[self removeObject:selected];
	}
}

- (UIColor*) colorForIndex:(int)objIndex
{
	switch(objIndex%7)
	{
		case 0:
			return [UIColor blueColor];
		case 1:
			return [UIColor greenColor];
		case 2:
			return [UIColor redColor];
		case 3:
			return [UIColor magentaColor];
		case 4:
			return [UIColor orangeColor];
		case 5:
			return [UIColor cyanColor];
		case 6:
			return [UIColor yellowColor];
	}
	
	return [UIColor grayColor];
}

#pragma mark adding objects

- (void) addManipulatedObject:(SharedObject*)theObject withTouches:(NSMutableSet*)manipulatingTouches
{	
	[currentlyManipulated addObject: theObject];
	[theObject trackTouches:manipulatingTouches];
	[theObject updateSelected];
	self.selected = theObject;
}

- (void) addSharedObject:(SharedObject*)theObject withTouches:(NSMutableSet*) creatingTouches
{
	@synchronized([SharedCollection sharedCollection].sharedObjects)
	{
		[[SharedCollection sharedCollection] addSharedObject:theObject];
	}
	
	[self addManipulatedObject:theObject withTouches:creatingTouches];
	colorIndex++;
	[[Sequencer sharedSequencer] refresh];
	
	[mainView allowSwitch];
}

- (void) addMultiPointWithTouches:(NSArray*)touches
{
	NSMutableArray * touchPoints = [NSMutableArray arrayWithCapacity:[touches count]];
	for(int i = 0; i < [touches count]; i++)
	{
		UITouch * curTouch = [touches objectAtIndex:i];
		CGPoint touchPoint = [curTouch locationInView:parentView];
		[touchPoints addObject:[NSValue value:&touchPoint withObjCType:@encode(CGPoint)]];
	}
	MultiPointObject * newMulti = [[MultiPointObject alloc] initWithView: parentView points:touchPoints];
	newMulti.baseColor = [self colorForIndex:colorIndex];
	
	[self addSharedObject:newMulti withTouches:[NSMutableSet setWithArray:touches]];
	[newMulti release];
}

#pragma mark touch timers

- (void) checkCreationTouch:(NSTimer*)theTimer
{
	UITouch * starter = [theTimer userInfo];
	if([startTouch isEqual:starter])
	{
		NSMutableArray * touches = [NSMutableArray arrayWithCapacity:1];
		[touches addObject:starter];
		
		for(UITouch * downTouch in downTouches)
		{
			if(![downTouch isEqual:starter])
			{
				if(![self isTouchControllingAnything:downTouch])
				{
					[touches addObject:downTouch];
				}
			}
		}
		
		[self addMultiPointWithTouches:touches];
		[self removeTouchTimer];
	}
}

- (void) removeTouchTimer
{
	[touchTimer invalidate];
	self.touchTimer = nil;
}

- (void) observedCreationTouch:(UITouch*)theTouch
{
	[self removeTouchTimer];
	
	self.startTouch = theTouch;
	self.touchTimer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:TOUCH_TIME] interval:1 target:self selector:@selector(checkCreationTouch:) userInfo:theTouch repeats:NO] autorelease];
	[[NSRunLoop currentRunLoop] addTimer:touchTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark touch functions

- (BOOL) isTouchControllingAnything:(UITouch*)theTouch
{
	for(SharedObject * obj in currentlyManipulated)
	{
		if([obj.controllingTouches containsObject:theTouch])
		{
			return YES;
		}
	}
	
	return NO;
}

//returns touches that aren't manipulating shit
- (NSSet*) manipulateWithTouches:(NSSet*)touches
{
	NSMutableSet * result = [NSMutableSet setWithSet:touches];
	NSArray * allObjects = [[SharedCollection sharedCollection] objects];
	for(int i = [allObjects count] - 1; i >= 0; i--)
	{
		SharedObject * curObject = [allObjects objectAtIndex:i];
		if([result count] == 0)
		{
			break;
		}
		NSMutableSet * curRelevantTouches = [curObject relevantTouches:result];
		if([curRelevantTouches count] > 0)
		{
			[self addManipulatedObject:curObject withTouches:curRelevantTouches];
			[result minusSet:curRelevantTouches];
		}
	}
	
	return result;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([touches containsObject:startTouch])
	{
		[self removeTouchTimer];
		self.startTouch = nil;
	}
	
	if([currentlyManipulated count] == 0)
	{
		self.selected = nil;
	}
	
	//NSLog(@"stopped tracking %d touches", [touches count]);
	
	NSMutableSet * toTrash = [NSMutableSet setWithCapacity:0];
	for(SharedObject * cur in currentlyManipulated)
	{
		if([cur stopTrackingTouches:touches])
		{
			[toTrash addObject:cur];
		}
	}
	
	for(SharedObject * cur in toTrash)
	{
		[cur updateUnselected];
		if([currentlyManipulated count] == 1)
		{
			self.selected = cur;
		}else{
			/*
			 if(cur.objectView != nil)
			 {
			 [self.view sendSubviewToBack:cur.objectView];
			 }
			 */
		}
		
		[currentlyManipulated removeObject:cur];
	}
	
	[downTouches minusSet:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(SharedObject * cur in currentlyManipulated)
	{
		[cur updateForTouches:touches];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[downTouches unionSet:touches];
	
	if([touches count] == 1)
	{
		UITouch * theTouch = [touches anyObject];
		if(theTouch.tapCount == TAPS_TO_DELETE && selected != nil)
		{
			[self removeSelectedObject];
		}
	}
	
	//check to see if touches are manipulating other objects and remove ones that are
	NSSet * touchesLeft = [self manipulateWithTouches:touches];
	//then go into object creation/extension logic
	if([touchesLeft count] == 0)//no more touches for creation
	{
		return;
	}if([touchesLeft count] == 1)
	{
		if([downTouches count] == 1)//ie the current one
		{
			[self observedCreationTouch:[touchesLeft anyObject]];
		}else {
			if([currentlyManipulated count] == 1)//only can extend if we are manipulating one at a time
			{
				MultiPointObject * manipulated = [currentlyManipulated anyObject];
				if([manipulated canAddControlPoint])//check to see that it's a candidate
				{
					NSMutableSet * remainingTouches = [NSMutableSet setWithSet:downTouches];
					[remainingTouches minusSet: manipulated.controllingTouches];
					if([remainingTouches count] == 1)
					{
						UITouch * theTouch = [remainingTouches anyObject];
						[manipulated addControlPointAtPosition:[theTouch locationInView:parentView]];
						[manipulated trackTouches:remainingTouches];
					}
				}
			}
		}
	}
}

@end
