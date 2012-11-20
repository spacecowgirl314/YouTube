//
//  PSCTransparentTableView.m
//  YouTube
//
//  Created by Chloe Stars on 11/7/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCTransparentTableView.h"

@implementation PSCTransparentTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
	
    [[self enclosingScrollView] setDrawsBackground: NO];
}

- (BOOL)isOpaque {
	
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
	
    // don't draw a background rect
}

- (NSMenu*)menuForEvent:(NSEvent*)theEvent {
    NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    int row=(int)[self rowAtPoint:pt];
	NSLog(@"menuForEvent %@ %@ %d",self, [self delegate], row);
	// only allow regular non-pseudo channels to show the menu
	if (row!=0 && row!=1 && row!=2)
	{
		// acquired help from http://www.cocoabuilder.com/archive/cocoa/242805-solved-with-reservations-re-turn-off-menu-highlight-in-outline-view.html#242823
		// do not use [super menuForEvent:theEvent], it will draw the stupid blue or white outline when clicked
		self.clickedRow=row;
		return [self menu];
	}
	else
	{
		return nil;
	}
}

@end
