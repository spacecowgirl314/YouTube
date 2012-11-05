//
//  PSCYouTubeVideoDataSource.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSCYouTubeSession.h"
#import "PSCYouTubeChannel.h"

@interface PSCYouTubeVideoDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
	PSCYouTubeSession *session;
	IBOutlet NSTableView *tableView;
	NSArray *videos;
}

- (void)refreshWithChannel:(PSCYouTubeChannel*)channel;

@end
