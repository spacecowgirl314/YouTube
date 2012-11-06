//
//  PSCWindowController.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSCWindowController : NSWindowController

@property IBOutlet NSSplitView *splitView;

- (void)uncollpaseRightView;

@end
