//
//  PSCWindowController.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGNoise.h"
#import "INAppStoreWindow.h"

@interface PSCWindowController : NSWindowController
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

- (void)uncollpaseRightView;

@end
