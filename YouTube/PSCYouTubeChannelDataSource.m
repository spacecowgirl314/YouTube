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

@end
