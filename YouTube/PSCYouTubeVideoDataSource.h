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
#import "EQSTRScrollView.h"

@interface PSCYouTubeVideoDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSSharingServicePickerDelegate>
{
	PSCYouTubeSession *session;
	IBOutlet EQSTRScrollView *scrollView;
	IBOutlet NSTableView *tableView;
	IBOutlet NSView *titleView;
	IBOutlet NSTextField *titleTextField;
	IBOutlet WebView *videoView;
	IBOutlet PSCWindowController *windowController;
	IBOutlet NSSearchField *searchField;
	NSArray *videos;
	NSThread *channelLoading;
}

- (void)refreshWithChannel:(PSCYouTubeChannel*)channel;
- (void)refreshWithWatchLater;
- (void)refreshWithSearch;
- (void)refreshWithMostPopular;

@end
