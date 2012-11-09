//
//  PSCTableRowView.m
//  YouTube
//
//  Created by Chloe Stars on 11/9/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCTableRowView.h"

@implementation PSCTableRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        //NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
		[[NSImage imageNamed:@"1.jpg.png"] drawInRect:self.bounds
						  fromRect:NSZeroRect
						 operation:NSCompositeCopy
						  fraction:1.0];
    }
}

@end
