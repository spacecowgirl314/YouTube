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

@end
