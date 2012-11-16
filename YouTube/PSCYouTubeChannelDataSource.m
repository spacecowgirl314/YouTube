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
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(reload:)
	 name:@"Authorized"
	 object:nil];
	
	PSCYouTubeAuthenticator *authenticator = [PSCYouTubeAuthenticator sharedAuthenticator];
	[authenticator setClientID:@"598067235549.apps.googleusercontent.com"];
	[authenticator setClientSecret:@"YAJBhZyscetPphUSlexBk7pR"];
	[authenticator setRedirectURL:[NSURL URLWithString:@"http://localhost:28247"]];
	if ([authenticator isAuthenticated])
	{
		[authenticator reauthorize];
	}
	else {
		NSURL *url = [authenticator URLToAuthorize];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
	
	session = [PSCYouTubeSession sharedSession];
	[session setDeveloperKey:@"AI39si5u0pQxyJgbcC10IQgk76osOWlrpQeSGyvSF3UXwUq1wqYOyYEiOm7tEecGjPqMOS6kcuR-yB75h8aDbM1N2FiOeYjBBQ"];
	[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
		NSMutableArray *arrayWithButtons = [NSMutableArray arrayWithArray:_channels];
		PSCYouTubeChannel *searchChannel = [PSCYouTubeChannel new];
		[searchChannel setDisplayName:@"Search"];
		PSCYouTubeChannel *watchLaterChannel = [PSCYouTubeChannel new];
		[watchLaterChannel setDisplayName:@"Watch Later"];
        PSCYouTubeChannel *mostPopularChannel = [PSCYouTubeChannel new];
        [mostPopularChannel setDisplayName:@"Most Popular"];
		[arrayWithButtons insertObject:searchChannel atIndex:0];
		[arrayWithButtons insertObject:watchLaterChannel atIndex:1];
        [arrayWithButtons insertObject:mostPopularChannel atIndex:2];
		channels = arrayWithButtons;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			if ([session userName]!=nil)
			{
				[userNameTextField setStringValue:[session userName]];
			}
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
	//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
		if (row==0)
		{
			[[result imageView] setImage:[NSImage imageNamed:@"search"]];
			[[result imageView] setImageScaling:NSImageScaleNone];
            //[[result imageView] setAlphaValue:0.5];
		}
		else if (row==1)
		{
			[[result imageView] setImage:[NSImage imageNamed:@"watchlater"]];
			[[result imageView] setImageScaling:NSImageScaleNone];
            //[[result imageView] setAlphaValue:0.5];
		}
        else if (row==2)
        {
            [[result imageView] setImage: [NSImage imageNamed:@"mostpopular"]];
            [[result imageView] setImageScaling:NSImageScaleNone];
            //[[result imageView] setAlphaValue:0.5];
        }
		else
		{
			NSURL *thumbnailURL = [(PSCYouTubeChannel*)[channels objectAtIndex:row] thumbnailURL];
			[[result imageView] setImage:[[NSImage alloc] initWithContentsOfURL:thumbnailURL]];
			[[result imageView] setImageScaling:NSImageScaleProportionallyUpOrDown];
            //[[result imageView] setAlphaValue:0.5];
		}
	//});
	return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    //NSTableRowView *rowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    //NSTableCellView *result = [rowView viewAtColumn:0];
    //[[result imageView] setAlphaValue:1.0];
    
	if (rowIndex==0)
	{
		[videoDataSource refreshWithSearch];
		[searchField setHidden:NO];
	}
	else if (rowIndex==1)
	{
		[videoDataSource refreshWithWatchLater];
		[searchField setHidden:YES];
	}
    else if (rowIndex==2)
    {
        [videoDataSource refreshWithMostPopular];
		[searchField setHidden:YES];
    }
	else
	{
		[videoDataSource refreshWithChannel:[channels objectAtIndex:rowIndex]];
		[searchField setHidden:YES];
	}
	
	[titleTextField setStringValue:[[channels objectAtIndex:rowIndex] displayName]];
	
	return YES;
    
}

// set style for the highlight of the cell
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
	return [PSCTableRowView new];
}

- (void)reload:(NSNotification*)notification
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[channelLoading cancel];
	channelLoading = [NSBlockOperation blockOperationWithBlock:^{
        // reattempt loading
		[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
			NSMutableArray *arrayWithButtons = [NSMutableArray arrayWithArray:_channels];
			PSCYouTubeChannel *searchChannel = [PSCYouTubeChannel new];
			[searchChannel setDisplayName:@"Search"];
			PSCYouTubeChannel *watchLaterChannel = [PSCYouTubeChannel new];
			[watchLaterChannel setDisplayName:@"Watch Later"];
			PSCYouTubeChannel *mostPopularChannel = [PSCYouTubeChannel new];
			[mostPopularChannel setDisplayName:@"Most Popular"];
			[arrayWithButtons insertObject:searchChannel atIndex:0];
			[arrayWithButtons insertObject:watchLaterChannel atIndex:1];
			[arrayWithButtons insertObject:mostPopularChannel atIndex:2];
			channels = arrayWithButtons;
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				if ([session userName]!=nil)
				{
					[userNameTextField setStringValue:[session userName]];
				}
				[tableView reloadData];
			});
		}];
    }];
	[channelLoading start];
}

@end
