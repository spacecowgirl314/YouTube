//
//  PSCYouTubeChannelDataSource.m
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeChannelDataSource.h"
#import "PSCYouTubeVideo.h"

@implementation PSCYouTubeChannelDataSource

- (id)init
{
	session = [PSCYouTubeSession new];
	[session setDeveloperKey:@"AI39si5u0pQxyJgbcC10IQgk76osOWlrpQeSGyvSF3UXwUq1wqYOyYEiOm7tEecGjPqMOS6kcuR-yB75h8aDbM1N2FiOeYjBBQ"];
	[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
		channels = _channels;
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
		NSURL *thumbnailURL = [(PSCYouTubeChannel*)[channels objectAtIndex:row] thumbnailURL];
		[[result imageView] setImage:[[NSImage alloc] initWithContentsOfURL:thumbnailURL]];
	});
	return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	[videoDataSource refreshWithChannel:[channels objectAtIndex:rowIndex]];
	[titleView setStringValue:[[channels objectAtIndex:rowIndex] displayName]];
	
	return YES;
}

- (void)reload
{
	[channelLoading cancel];
	channelLoading = [NSBlockOperation blockOperationWithBlock:^{
        // reattempt loading
		[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
			channels = _channels;
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
