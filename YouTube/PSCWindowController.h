//
//  PSCWindowController.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGNoise.h"

@interface PSCWindowController : NSWindowController

@property IBOutlet NSTableView *channelTableView;
@property IBOutlet NSScrollView *channelScrollView;
@property IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet KGNoiseView *noiseView;

- (void)uncollpaseRightView;

@end
