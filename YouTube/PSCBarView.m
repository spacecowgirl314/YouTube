//
//  PSCBarView.m
//  YouTube
//
//  Created by Chloe Stars on 11/24/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCBarView.h"

@implementation PSCBarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setWantsLayer:YES];
		//[[self layer] setMasksToBounds:YES];
		//[[self layer] setCornerRadius:5.0];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSBezierPath* roundRectPath = [NSBezierPath bezierPathWithRoundedRect: [self bounds] xRadius:5 yRadius:5];
    [roundRectPath addClip];
	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.324f green: 0.331f blue: 0.347f alpha: 0.7],
							 (CGFloat)0, [NSColor colorWithDeviceRed: 0.245f green: 0.253f blue: 0.269f alpha: 0.7], .5f,
							 [NSColor colorWithDeviceRed: 0.206f green: 0.214f blue: 0.233f alpha: 0.7], .5f,
							 [NSColor colorWithDeviceRed: 0.139f green: 0.147f blue: 0.167f alpha: 0.7], 1.0f, nil];
	[gradient drawInBezierPath:roundRectPath angle:270];
}

@end
