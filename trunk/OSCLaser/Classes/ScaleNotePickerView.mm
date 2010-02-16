//
//  ScaleNotePickerView.m
//  OSCLaser
//
//  Created by Ben Cunningham on 2/16/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ScaleNotePickerView.h"
#import "SharedUtility.h"
#import "NoteObject.h"

#define NOTE_PADDING 3

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
	UIColor * selectedColor = [UIColor lightGrayColor];
	if(selected)
	{
		selectedColor = [UIColor blueColor];
	}
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	[selectedColor set];
	
	CGContextFillRect(currentContext, rect);
	[[UIColor whiteColor] set];
	CGContextStrokeRectWithWidth(currentContext, rect, 2.0);
}

#define TEXT_OFFSET 13

- (void)drawRect:(CGRect)rect {
	float width = rect.size.width/[notes count];
	UIFont *systemFont = [UIFont boldSystemFontOfSize:16.0];
    for(int i = 0; i < [notes count]; i++)
	{
		NoteObject * curNote = [notes objectAtIndex:i];
		CGRect currentRect = CGRectMake(i*width + NOTE_PADDING, NOTE_PADDING, width - 2*NOTE_PADDING, rect.size.height - 2*NOTE_PADDING);
		[self drawSquare: currentRect selected:curNote.isOn];
		currentRect.origin.y = TEXT_OFFSET;
		currentRect.size.height = currentRect.size.height - TEXT_OFFSET;
		if(curNote.isOn)
		{
			[[UIColor whiteColor] set];
		}else{
			[[UIColor darkGrayColor] set];
		}
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
	NoteObject * touched = [notes objectAtIndex:noteIndex];
	[touched toggle];
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
