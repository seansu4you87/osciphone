//
//  ScaleNotePickerView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/16/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ScaleNotePickerView.h"
#import "SharedUtility.h"

#define NOTE_PADDING 2

@implementation ScaleNotePickerView

@synthesize notes;


/*
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        notes = [[NSMutableArray array] retain];
    }
    return self;
}
 */

- (void)drawSquare:(CGRect)rect selected:(BOOL)selected
{
	UIColor * selectedColor = [UIColor grayColor];
	if(selected)
	{
		selectedColor = [UIColor blueColor];
	}
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	[selectedColor set];
	CGContextSetLineWidth(currentContext, 1);
	CGContextFillRect(currentContext, rect);
}

#define TEXT_OFFSET 13

- (void)drawRect:(CGRect)rect {
	float width = rect.size.width/[notes count];
	UIFont *systemFont = [UIFont boldSystemFontOfSize:16.0];
    for(int i = 0; i < [notes count]; i++)
	{
		CGRect currentRect = CGRectMake(i*width + NOTE_PADDING, NOTE_PADDING, width - 2*NOTE_PADDING, rect.size.height - 2*NOTE_PADDING);
		[self drawSquare: currentRect selected:random];
		currentRect.origin.y = TEXT_OFFSET;
		currentRect.size.height = currentRect.size.height - TEXT_OFFSET;
		[[UIColor whiteColor] set];
		[[NSString stringWithFormat:@"%d", i+1] drawInRect:currentRect withFont:systemFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		
	}
}

- (void) setCurrentNotes:(NSMutableArray*)newNotes
{
	if(notes == nil)
	{
		notes = [[NSMutableArray arrayWithCapacity:[newNotes count]] retain];
	}
	
	[notes removeAllObjects];
	[notes addObjectsFromArray:newNotes];
	[self setNeedsDisplay];
}

- (void) toggleNoteAtIndex:(int)noteIndex
{
	NSLog(@"index:%d", noteIndex+1);
	random = !random;
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	int noteIndex = touchPoint.x/(self.frame.size.width/[notes count]);
	[self toggleNoteAtIndex:noteIndex];
}

- (void)dealloc {
	[notes release];
    [super dealloc];
}


@end
