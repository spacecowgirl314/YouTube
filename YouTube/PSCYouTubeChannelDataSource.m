//
//  PSCYouTubeChannelDataSource.m
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeChannelDataSource.h"

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

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
	NSURL *thumbnailURL = [(PSCYouTubeChannel*)[channels objectAtIndex:row] thumbnailURL];
	[[result imageView] setImage:[[NSImage alloc] initWithContentsOfURL:thumbnailURL]];
	return result;
}

- (void)reload
{
	// reattempt loading
	[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
		channels = _channels;
	}];
	[tableView reloadData];
}

- (IBAction)pressedReloadButton:(id)sender
{
	[self reload];
}

@end
