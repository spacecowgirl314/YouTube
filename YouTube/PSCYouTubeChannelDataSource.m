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

// this is the real number of buttons and not the -1 shifted crap that NSArrays return
#define kExtraButtons 3

@implementation PSCYouTubeChannelDataSource

- (id)init
{
	// for some reason this wants to load more than once... refuse it
	static dispatch_once_t once;
	dispatch_once(&once, ^{
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(reload:)
	 name:@"ReloadChannels"
	 object:nil];
	
	PSCYouTubeAuthenticator *authenticator = [PSCYouTubeAuthenticator sharedAuthenticator];
	[authenticator setClientID:@"598067235549.apps.googleusercontent.com"];
	[authenticator setClientSecret:@"YAJBhZyscetPphUSlexBk7pR"];
	[authenticator setRedirectURL:[NSURL URLWithString:@"http://localhost:28247"]];
	/* uncomment this to reset the login and start fresh
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refresh_token"];
	 */
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
	
	// set up array and display them before we load the channels
	channels = [NSMutableArray new];
	PSCYouTubeChannel *searchChannel = [PSCYouTubeChannel new];
	[searchChannel setDisplayName:@"Search"];
	PSCYouTubeChannel *watchLaterChannel = [PSCYouTubeChannel new];
	[watchLaterChannel setDisplayName:@"Watch Later"];
	PSCYouTubeChannel *mostPopularChannel = [PSCYouTubeChannel new];
	[mostPopularChannel setDisplayName:@"Most Popular"];
	[channels insertObject:searchChannel atIndex:0];
	[channels insertObject:watchLaterChannel atIndex:1];
	[channels insertObject:mostPopularChannel atIndex:2];
	
	NSRange range = NSMakeRange(0, kExtraButtons);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideUp];
	
	[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
		[channels addObjectsFromArray:_channels];
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			if ([session userName]!=nil)
			{
				[userNameTextField setStringValue:[session userName]];
			}
			NSRange range = NSMakeRange(kExtraButtons, [_channels count]);
			NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
			[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
			
			// allow you to scroll to refresh.. using [self reload:nil] here causes it to panic about something strong retain
			[scrollView setRefreshBlock:^(EQSTRScrollView *scrollView) {
				[[NSNotificationCenter defaultCenter]
				 postNotificationName:@"ReloadChannels"
				 object:nil];
			}];
		});
	}];
	});
	
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
			/*dispatch_async(dispatch_get_main_queue(), ^(void) {
			[[result imageView] setImage:nil];
			});*/
			//NSURL *thumbnailImage = [(PSCYouTubeChannel*)[channels objectAtIndex:row] thumbnailURL];
			//NSImage *downloadedImage = [[NSImage alloc] initWithContentsOfURL:thumbnailURL];
			[[result imageView] setImage:[(PSCYouTubeChannel*)[channels objectAtIndex:row] channelImage]];
			[[result imageView] setImageScaling:NSImageScaleProportionallyUpOrDown];
            //[[result imageView] setAlphaValue:0.5];
		}
	});
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
	// remove current rows if present
	NSRange range = NSMakeRange(kExtraButtons, [channels count]-kExtraButtons);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	// remove objects from the table and the array
	[channels removeObjectsAtIndexes:theSet];
	[tableView removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideUp];
	channelLoading = [NSBlockOperation blockOperationWithBlock:^{
        // reattempt loading
		[session subscriptionsWithCompletion:^(NSArray *_channels, NSError *error) {
			[channels addObjectsFromArray:_channels];
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				if ([session userName]!=nil)
				{
					[userNameTextField setStringValue:[session userName]];
				}
				NSRange range = NSMakeRange(kExtraButtons, [_channels count]);
				NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
				[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
				[scrollView stopLoading];
			});
		}];
    }];
	[channelLoading start];
}

- (IBAction)reloadPressed:(id)sender
{
	[self reload:nil];
}

- (IBAction)unsubscribeChannel:(id)sender
{
	NSLog(@"clicked row:%ld",[tableView clickedRow]);
	[session unsubscribeWithChannel:[channels objectAtIndex:[tableView clickedRow]] completion:^(NSError *error) {
		if (error==nil)
		{
			NSRange range = NSMakeRange([tableView clickedRow], [tableView clickedRow]);
			NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
			[tableView removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideUp];
			[channels removeObjectAtIndex:[tableView clickedRow]];
		}
	}];
}

@end
