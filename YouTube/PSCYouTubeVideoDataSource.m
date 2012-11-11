//
//  PSCYouTubeVideoDataSource.m
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeVideoDataSource.h"
#import "PSCYouTubeVideoCellView.h"
#import "PSCYouTubeVideo.h"
#import "NSDate+TimeAgo.h"

@implementation PSCYouTubeVideoDataSource

- (id)init
{
	session = [PSCYouTubeSession sharedSession];
	
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [videos count];
}

- (id)tableView:(NSTableView *)_tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	PSCYouTubeVideoCellView *result = [_tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
	PSCYouTubeVideo *video = [videos objectAtIndex:row];
	[[result titleField] setStringValue:[video title]];
	NSURL *thumbnailURL = [video thumbnailURL];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
		[[result thumbnailView] setImage:nil];
		[[result thumbnailView] setImage:[[NSImage alloc] initWithContentsOfURL:thumbnailURL]];
	});
	[[result descriptionField] setStringValue:[video description]];
	
	[[result timeAgoField] setStringValue:[[video publishedDate] timeAgo]];
	
	// format listener and play count with commas/separators
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setGroupingSize:3];
	[numberFormatter setUsesGroupingSeparator:YES];
	NSString *formattedViewCount = [numberFormatter stringFromNumber:[video viewCount]];
	
	NSString *viewsString = [[NSString alloc] initWithFormat:@"%@ views", formattedViewCount];
	
	[[result viewCountField] setStringValue:viewsString];
	[[result uploaderTextField] setStringValue:[video uploader]];
	
	return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	// add autoplay to the end of the URL
	NSString *videoURLString = [[NSString alloc] initWithFormat:@"%@&autoplay=1&theme=light&modestbranding=1", [(PSCYouTubeVideo*)[videos objectAtIndex:rowIndex] videoURL]];
	//NSString *swfHTML = [[NSString alloc] initWithFormat:@"<embed src=\"%@\" quality=\"high\" name=\"show\" width=\"100%%\" height=\"100%%\" allowScriptAccess=\"sameDomain\" allowFullScreen=\"true\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" SCALE=\"exactfit\" />", videoURLString];
	NSString *swfHTML = [[NSString alloc] initWithFormat:@"<html><body style='overflow:hide;'><object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0\" width=\"100%%\" height=\"100%%\"><param name=\"movie\" value=\"%@\" /><param name=\"quality\" value=\"high\" /><PARAM NAME=\"SCALE\" VALUE=\"exactfit\"><embed src=\"%@\" quality=\"high\" type=\"application/x-shockwave-flash\" width=\"100%%\" height=\"100%%\" SCALE=\"exactfit\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" /></object></body></html>", videoURLString, videoURLString];
	[[videoView mainFrame] loadHTMLString:swfHTML baseURL:nil];
	//[[videoView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoURLString]]];
	// document.getElementById("mainVidEmbed").allowFullScreen ="true"
	
	[windowController uncollpaseRightView];
	return YES;
}

- (void)refreshWithChannel:(PSCYouTubeChannel*)channel
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[session subscriptionWithChannel:channel completion:^(NSArray *_videos, NSError *error) {
			videos = _videos;
			// don't do anything
			/*for (PSCYouTubeVideo *video in videos) {
			 NSLog(@"title:%@", [video title]);
			 NSLog(@"thumbnailURL:%@", [video thumbnailURL]);
			 NSLog(@"description:%@", [video description]);
			 NSLog(@"viewCount:%@", [video viewCount]);
			 NSLog(@"videoURL:%@", [video videoURL]);
			 }*/
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[tableView reloadData];
				[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
				[scrollView reflectScrolledClipView: [scrollView contentView]];
			});
		}];
	});
}

- (void)refreshWithWatchLater
{
	[session watchLaterWithCompletion:^(NSArray *_videos, NSError *error) {
		videos = _videos;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[tableView reloadData];
			[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
			[scrollView reflectScrolledClipView: [scrollView contentView]];
		});
	}];
}

- (void)refreshWithSearch
{
	// this shouldn't load any videos into the table (in fact it should clear them), it should bring up the search box as part of the table view
	videos = [NSArray new];
	[tableView reloadData];
	[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
	[scrollView reflectScrolledClipView: [scrollView contentView]];
	[self refreshSearchWithQuery:nil];
}

- (IBAction)refreshSearchWithQuery:(id)sender
{
	if (![[searchField stringValue] isEqualToString:@""])
	{
		[titleTextField setStringValue:[[NSString alloc] initWithFormat:@"Search - %@", [searchField stringValue]]];
		[session searchWithQuery:[searchField stringValue] completion:^(NSArray *_videos, NSError *error) {
			videos = _videos;
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[tableView reloadData];
				[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
				[scrollView reflectScrolledClipView: [scrollView contentView]];
			});
		}];
	}
}

- (void)refreshWithMostPopular
{
	[session mostPopularWithCompletion:^(NSArray *_videos, NSError *error) {
		videos = _videos;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[tableView reloadData];
			[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
			[scrollView reflectScrolledClipView: [scrollView contentView]];
		});
	}];
}
- (IBAction)share:(id)sender
{
	NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:@[[[videos objectAtIndex:[tableView selectedRow]] siteURL]]];
	sharingServicePicker.delegate = self;
	[sharingServicePicker showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
}

- (IBAction)openInBrowser:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[[videos objectAtIndex:[tableView selectedRow]] siteURL]];
}

- (NSArray *)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker sharingServicesForItems:(NSArray *)items proposedSharingServices:(NSArray *)proposedServices
{
	NSMutableArray *modifiedProposals = [NSMutableArray new];
	for (NSSharingService *proposedService in proposedServices) {
		if (![[proposedService title] isEqualToString:@"Add to Reading List"]) {
			[modifiedProposals addObject:proposedService];
		}
		//NSLog (@"title:%@", [proposedService title]);
	}

	return modifiedProposals;
}

@end
