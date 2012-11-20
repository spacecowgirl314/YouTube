//
//  PSCWindowController.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebUIDelegate.h>
#import "KGNoise.h"
#import "INAppStoreWindow.h"

@interface PSCWindowController : NSWindowController <NSWindowDelegate>
{
	BOOL isTogglingSidebar;
}

@property IBOutlet INAppStoreWindow *window;
@property IBOutlet NSView *titleView;
@property IBOutlet NSTableView *channelTableView;
@property IBOutlet NSScrollView *channelScrollView;
@property IBOutlet NSSplitView *splitView;
@property IBOutlet NSButton *toggleSidebarButton;
@property (weak) IBOutlet KGNoiseView *noiseView;
@property (weak) IBOutlet KGNoiseLinearGradientView *leftNoiseView;
@property (weak) IBOutlet KGNoiseLinearGradientView *rightNoiseView;
@property IBOutlet WebView *videoView;
@property IBOutlet NSBox *titleDivider;
@property IBOutlet NSWindow *loginSheet;

- (void)uncollpaseRightView;

@end
