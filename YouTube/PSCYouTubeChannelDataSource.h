//
//  PSCYouTubeChannelDataSource.h
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSCYouTube.h"
#import "PSCYouTubeVideoDataSource.h"
#import "EQSTRScrollView.h"

@interface PSCYouTubeChannelDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
	PSCYouTubeSession *session;
	NSMutableArray *channels;
	IBOutlet NSTableView *tableView;
	IBOutlet NSTextField *titleTextField;
	IBOutlet NSTextField *userNameTextField;
	IBOutlet NSSearchField *searchField;
	IBOutlet PSCYouTubeVideoDataSource *videoDataSource;
	IBOutlet EQSTRScrollView *scrollView;
	NSOperation *channelLoading;
}

- (IBAction)reloadPressed:(id)sender;
- (void)reload:(NSNotification*)notification;

@end
