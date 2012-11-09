//
//  PSCYouTubeChannelDataSource.m
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeChannelDataSource.h"
#import "PSCYouTubeVideo.h"
#import "PSCTableRowView.h"

@implementation PSCYouTubeChannelDataSource

- (id)init
{
	session = [PSCYouTubeSession new];
	[session setDeveloperKey:@"AI39si5u0pQxyJgbcC10IQgk76osOWlrpQeSGyvSF3UXwUq1wqYOyYEiOm7tEecGjPqMOS6kcuR-yB75h8aDbM1N2FiOeYjBBQ"];
	[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
		NSMutableArray *arrayWithButtons = [NSMutableArray arrayWithArray:_channels];
		PSCYouTubeChannel *searchChannel = [PSCYouTubeChannel new];
		[searchChannel setDisplayName:@"Search"];
		PSCYouTubeChannel *mostPopularChannel = [PSCYouTubeChannel new];
		[mostPopularChannel setDisplayName:@"Most Popular"];
		[arrayWithButtons insertObject:searchChannel atIndex:0];
		[arrayWithButtons insertObject:mostPopularChannel atIndex:1];
		//[arrayWithButtons
		channels = arrayWithButtons;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[tableView reloadData];
		});
	}];
	
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [channels count];
}

- (id)tableView:(NSTableView *)_tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *result = [_tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
		if (row==0)
		{
			[[result imageView] setImage:[NSImage imageNamed:@"search"]];
		}
		else if (row==1)
		{
			[[result imageView] setImage:[NSImage imageNamed:@"1.jpg.png"]];
		}
		else
		{
			NSURL *thumbnailURL = [(PSCYouTubeChannel*)[channels objectAtIndex:row] thumbnailURL];
			[[result imageView] setImage:[[NSImage alloc] initWithContentsOfURL:thumbnailURL]];
		}
	});
	return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if (rowIndex==0)
	{
		[videoDataSource refreshWithSearch];
		[titleView setStringValue:@"Search - Troy and Abed in the Morning"];
	}
	else if (rowIndex==1)
	{
		[videoDataSource refreshWithWatchLater];
		[titleView setStringValue:@"Watch Later"];
	}
	else
	{
		[videoDataSource refreshWithChannel:[channels objectAtIndex:rowIndex]];
		[titleView setStringValue:[[channels objectAtIndex:rowIndex] displayName]];
	}
	
	return YES;
}

// set style for the highlight of the cell
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
	return [PSCTableRowView new];
}

- (void)reload
{
	[channelLoading cancel];
	channelLoading = [NSBlockOperation blockOperationWithBlock:^{
        // reattempt loading
		[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
			NSMutableArray *arrayWithButtons = [NSMutableArray arrayWithArray:_channels];
			PSCYouTubeChannel *searchChannel = [PSCYouTubeChannel new];
			[searchChannel setDisplayName:@"Search"];
			PSCYouTubeChannel *mostPopularChannel = [PSCYouTubeChannel new];
			[mostPopularChannel setDisplayName:@"Most Popular"];
			[arrayWithButtons insertObject:searchChannel atIndex:0];
			[arrayWithButtons insertObject:mostPopularChannel atIndex:1];
			//[arrayWithButtons
			channels = arrayWithButtons;
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[tableView reloadData];
			});
		}];
    }];
	[channelLoading start];
}

- (IBAction)pressedReloadButton:(id)sender
{
	[self reload];
}

@end
