//
//  PSCTransparentCellView.m
//  YouTube
//
//  Created by Chloe Stars on 11/7/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCTransparentCellView.h"

@implementation PSCTransparentCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (BOOL)isOpaque {
	
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
	
    // don't draw a background rect
}


@end
