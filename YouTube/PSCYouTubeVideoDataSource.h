//
//  PSCYouTubeVideoDataSource.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PSCYouTubeSession.h"
#import "PSCYouTubeChannel.h"
#import "PSCWindowController.h"

@interface PSCYouTubeVideoDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSSharingServicePickerDelegate>
{
	PSCYouTubeSession *session;
	IBOutlet NSScrollView *scrollView;
	IBOutlet NSTableView *tableView;
	IBOutlet NSView *titleView;
	IBOutlet NSTextField *titleTextField;
	IBOutlet WebView *videoView;
	IBOutlet PSCWindowController *windowController;
	IBOutlet NSSearchField *searchField;
	NSArray *videos;
}

- (void)refreshWithChannel:(PSCYouTubeChannel*)channel;
- (void)refreshWithWatchLater;
- (void)refreshWithSearch;
- (void)refreshWithMostPopular;

@end
