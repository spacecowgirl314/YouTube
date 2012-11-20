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
@synthesize window;
@synthesize titleView;
@synthesize channelTableView;
@synthesize channelScrollView;
@synthesize splitView;
@synthesize noiseView;
@synthesize leftNoiseView;
@synthesize rightNoiseView;
@synthesize toggleSidebarButton;
@synthesize videoView;
@synthesize loginSheet;

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
	
	//[videoView setUIDelegate:self];
	
	/*[channelScrollView setBackgroundColor:[NSColor clearColor]];
	//[channelScrollView setDrawsBackground:NO];
	[channelTableView setBackgroundColor:[NSColor greenColor]];*/
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowDidResize:(NSNotification*)notification
{
	NSView *right = [[[self splitView] subviews] objectAtIndex:1];
	if (!isTogglingSidebar)
	{
		// adjust the toggle button to be in the proper positon at start
		if (right.frame.size.width > 0)
		{
			[[self titleDivider] setHidden:NO];
			[[self toggleSidebarButton] setImage:[NSImage imageNamed:@"togglereverse"]];
		}
		else
		{
			[[self titleDivider] setHidden:YES];
			[[self toggleSidebarButton] setImage:[NSImage imageNamed:@"toggle"]];
		}
	}
	else
	{
		// now that toggling has stopped resume resize detection
		if (right.frame.size.width == 0)
		{
			[[self titleDivider] setHidden:YES];
			isTogglingSidebar = NO;
		}
	}
}

- (void)awakeFromNib
{
	// setting the delegate allows me to use the NSMenus on right-click/cntrl-click with INAppStoreWindow
	self.window.delegate=self;
	self.window.trafficLightButtonsLeftMargin = 7.0;
    self.window.fullScreenButtonRightMargin = 7.0;
    self.window.hideTitleBarInFullScreen = YES;
    self.window.centerFullScreenButton = YES;
    self.window.titleBarHeight = 33.0;
	
	// self.titleView is a an IBOutlet to an NSView that has been configured in IB with everything you want in the title bar
	self.titleView.frame = self.window.titleBarView.bounds;
	self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.titleBarView addSubview:self.titleView];
	
	[noiseView setBackgroundColor:[NSColor colorWithHexColorString:@"202020"]];
	[noiseView setNoiseOpacity:0.04f];
	
	[leftNoiseView setBackgroundColor:[NSColor colorWithHexColorString:@"dadada"]];
	[leftNoiseView setAlternateBackgroundColor:[NSColor colorWithHexColorString:@"a6a6a6"]];
	[leftNoiseView setNoiseBlendMode:kCGBlendModeMultiply];
	[leftNoiseView setNoiseOpacity:0.04f];
	
	[rightNoiseView setBackgroundColor:[NSColor colorWithHexColorString:@"dadada"]];
	[rightNoiseView setAlternateBackgroundColor:[NSColor colorWithHexColorString:@"a6a6a6"]];
	[rightNoiseView setNoiseBlendMode:kCGBlendModeMultiply];
	[rightNoiseView setNoiseOpacity:0.04f];
	
	// adjust the toggle button to be in the proper positon at start
	NSView *right = [[[self splitView] subviews] objectAtIndex:1];
	if (right.frame.size.width > 0)
	{
		[[self toggleSidebarButton] setImage:[NSImage imageNamed:@"togglereverse"]];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowDidResize:)
												 name:NSWindowDidResizeNotification
											   object:[self window]];
	
	// Work in progress, trying to get self-contained login to work
	/*[NSApp beginSheet:loginSheet modalForWindow:window
		modalDelegate:self didEndSelector:NULL contextInfo:nil];*/
	//[NSApp runModalForWindow: loginSheet];
    // Sheet is up here.
    //[NSApp endSheet: loginSheet];
    //[loginSheet orderOut: self];
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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// received help from http://www.manicwave.com/blog/2009/12/31/unraveling-the-mysteries-of-nssplitview-part-2/
		NSView *left  = [[[self splitView] subviews] objectAtIndex:0];
		NSView *right = [[[self splitView] subviews] objectAtIndex:1];
		// save the right view width if it's greater than the default, otherwise reset it
		if (right.frame.size.width > kRightViewWidth)
		{
			[[NSUserDefaults standardUserDefaults] setFloat:right.frame.size.width forKey:@"rightViewWidth"];
		}
		else
		{
			[[NSUserDefaults standardUserDefaults] setFloat:kRightViewWidth forKey:@"rightViewWidth"];
		}
		NSRect leftFrame = [left frame];
		NSRect rect = self.window.frame;
		rect.size.width = leftFrame.size.width;
		isTogglingSidebar = YES;
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			//[[self titleDivider] setHidden:YES];
			[[self toggleSidebarButton] setImage:[NSImage imageNamed:@"toggle"]];
			[[self window] setFrame:rect display:YES animate:YES];
			[[self splitView] display];
		});
	});
}

- (void)uncollpaseRightView
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSView *right = [[[self splitView] subviews] objectAtIndex:1];
		// the double if statment is for the YouTube video data source
		if (right.frame.size.width <= 0)
		{
			NSRect rect = self.window.frame;
			// only set the right view width if the key exists
			if ([[NSUserDefaults standardUserDefaults] floatForKey:@"rightViewWidth"]!=0)
			{
				// if we changed the width then keep it
				rect.size.width = rect.size.width+[[NSUserDefaults standardUserDefaults] floatForKey:@"rightViewWidth"];
			}
			else
			{
				rect.size.width = rect.size.width+kRightViewWidth;
			}
			isTogglingSidebar = YES;
			
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[[self titleDivider] setHidden:NO];
				[[self toggleSidebarButton] setImage:[NSImage imageNamed:@"togglereverse"]];
				[[self window] setFrame:rect display:YES animate:YES];
				[[self splitView] display];
			});
		}
	});
}

- (IBAction)toggleSidebar:(id)sender
{
	NSView *left = [[[self splitView] subviews] objectAtIndex:0];
	if (left.frame.size.width <= 0)
	{
		[self uncollpaseLeftView];
	}
	else {
		[self collapseLeftView];
	}
}

- (void)collapseLeftView
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// received help from http://www.manicwave.com/blog/2009/12/31/unraveling-the-mysteries-of-nssplitview-part-2/
		NSView *left  = [[[self splitView] subviews] objectAtIndex:0];
		NSRect leftFrame = [left frame];
		NSRect rect = self.window.frame;
		rect.size.width = leftFrame.size.width;
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[left setFrame:rect];
			//[[self window] setFrame:rect display:YES animate:YES];
			[[self splitView] display];
		});
	});
}

- (void)uncollpaseLeftView
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSView *left = [[[self splitView] subviews] objectAtIndex:0];
		// the double if statment is for the YouTube video data source
		if (left.frame.size.width <= 0)
		{
			NSRect rect = self.window.frame;
			rect.size.width = rect.size.width+kRightViewWidth;
			
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[[self window] setFrame:rect display:YES animate:YES];
				[[self splitView] display];
			});
		}
	});
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	NSLog(@"request: %@", [sender mainFrameURL]);
	[[NSWorkspace sharedWorkspace] openURL:[request URL]];
	return nil;
	
}

@end
