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

@interface PSCYouTubeChannelDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
	PSCYouTubeSession *session;
	NSArray *channels;
	IBOutlet NSTableView *tableView;
	IBOutlet NSTextField *titleView;
	IBOutlet PSCYouTubeVideoDataSource *videoDataSource;
	NSOperation *channelLoading;
}

@end
