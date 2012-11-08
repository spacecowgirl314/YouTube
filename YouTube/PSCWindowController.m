//
//  PSCWindowController.m
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCWindowController.h"
#import "NSColor+Hex.h"

#define kRightViewWidth 630

@interface PSCWindowController ()

@end

@implementation PSCWindowController
@synthesize channelTableView;
@synthesize channelScrollView;
@synthesize splitView;
@synthesize noiseView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	/*[channelScrollView setBackgroundColor:[NSColor clearColor]];
	//[channelScrollView setDrawsBackground:NO];
	[channelTableView setBackgroundColor:[NSColor greenColor]];*/
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib
{
	[noiseView setBackgroundColor:[NSColor colorWithHexColorString:@"202020"]];
	[noiseView setNoiseOpacity:0.03f];
}

- (IBAction)toggleVideo:(id)sender
{
	NSView *right = [[[self splitView] subviews] objectAtIndex:1];
	if (right.frame.size.width <= 0)
	{
		[self uncollpaseRightView];
	}
	else {
		[self collapseRightView];
	}
}

- (void)collapseRightView
{
	// received help from http://www.manicwave.com/blog/2009/12/31/unraveling-the-mysteries-of-nssplitview-part-2/
    NSView *left  = [[[self splitView] subviews] objectAtIndex:0];
    NSRect leftFrame = [left frame];
	NSRect rect = self.window.frame;
	rect.size.width = leftFrame.size.width;
	
	[[self window] setFrame:rect display:YES animate:YES];
    [[self splitView] display];
}

- (void)uncollpaseRightView
{
	NSView *right = [[[self splitView] subviews] objectAtIndex:1];
	// the double if statment is for the YouTube video data source
	if (right.frame.size.width <= 0)
	{
		NSRect rect = self.window.frame;
		rect.size.width = rect.size.width+kRightViewWidth;
		
		[[self window] setFrame:rect display:YES animate:YES];
		[[self splitView] display];
	}
}

@end
