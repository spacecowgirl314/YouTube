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
#import "HCYoutubeParser.h"

static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;

@implementation PSCYouTubeVideoDataSource
@synthesize playerLayer;

- (id)init
{
	session = [PSCYouTubeSession sharedSession];
	
	return self;
}

- (void)awakeFromNib
{
	/*[nativeView setWantsLayer:YES];
	[[nativeView layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
	player = [[AVPlayer alloc] init];
	
	// setup player
	AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	[newPlayerLayer setFrame:[[nativeView layer] bounds]];
	[newPlayerLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
	[[nativeView layer] addSublayer:newPlayerLayer];
	[self setPlayerLayer:newPlayerLayer];*/
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

NSInteger qualityForKey(NSString *key)
{
	// because there's no NSSwitch statement :(
	if ([key isEqualToString:@"hd1080"])
		return 4;
	if ([key isEqualToString:@"hd720"])
		return 3;
	if ([key isEqualToString:@"medium"])
		return 2;
	if ([key isEqualToString:@"small"])
		return 1;
	return 0;
}

NSInteger qualitySort(id object1, id object2, void *context)
{
	NSInteger v1 = qualityForKey(object1);
	NSInteger v2 = qualityForKey(object2);
	if (v1 < v2)
		return NSOrderedDescending;
	else if (v1 > v2)
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
	NSDictionary *qualityDictionary = [HCYoutubeParser h264videosWithYoutubeURL:[(PSCYouTubeVideo*)[videos objectAtIndex:rowIndex] siteURL]];
	if ([[qualityDictionary allValues] count] !=0)
	{
		// hide WebView and remove what's playing
		dispatch_async(dispatch_get_main_queue(), ^(void) {
		[[videoView mainFrame] loadHTMLString:@"" baseURL:nil];
			[nativeView setHidden:NO];
		[videoView setHidden:YES];
		 });
		
		NSString *videoURL;
		if (YES/*HIGHEST_QUALITY*/)
		{
			// select the highest quality video by using some special objective-c voodoo and some hardcoded string qualities
			NSArray *sortedKeys = [[qualityDictionary allKeys] sortedArrayUsingFunction:qualitySort context:NULL];
			NSLog(@"sorted qualities:%@", sortedKeys);
			NSLog(@"quality being loaded:%@", [sortedKeys objectAtIndex:0]);
			videoURL = [qualityDictionary objectForKey:[sortedKeys objectAtIndex:0]];
		}
		else
		{
			// medium quality would be chosen here but if on retina hd720 be would be the default
		}
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
		AVURLAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:videoURL]];
		AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
		[nativeView setPlayerItem:playerItem completion:^{
			[nativeView play];
		}];
		});
	}
	else
	{
		// add autoplay to the end of the URL
		
		NSString *videoURLString = [[NSString alloc] initWithFormat:@"%@&autoplay=1&theme=light&modestbranding=1", [(PSCYouTubeVideo*)[videos objectAtIndex:rowIndex] videoURL]];
		NSString *swfHTML = [[NSString alloc] initWithFormat:@"<html><body style='margin:0;padding:0;'><object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0\" width=\"100%%\" height=\"100%%\"><param name=\"movie\" value=\"%@\" /><param name=\"quality\" value=\"high\" /><PARAM NAME=\"SCALE\" VALUE=\"exactfit\"><embed src=\"%@\" quality=\"high\" allowFullScreen=\"true\" type=\"application/x-shockwave-flash\" width=\"100%%\" height=\"100%%\" SCALE=\"exactfit\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" /></object></body></html>", videoURLString, videoURLString];
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[nativeView setPlayerItem:nil completion:^{
				// do nothing
			}];
			[nativeView setHidden:YES];
			[videoView setHidden:NO];
			[[videoView mainFrame] loadHTMLString:swfHTML baseURL:[NSURL URLWithString:@"http://youtube.com/"]];
		});
		//[[videoView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoURLString]]]; regular sans fullscreen
	}
	});
	
	[windowController uncollpaseRightView];
	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == AVSPPlayerLayerReadyForDisplay)
	{
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES)
		{
			// The AVPlayerLayer is ready for display. Hide the loading spinner and show it.
			//[self stopLoadingAnimationAndHandleError:nil];
			//[[self playerLayer] setHidden:NO];
			[player play];
		}
	}
}

- (void)refreshWithChannel:(PSCYouTubeChannel*)channel
{
	// remove current rows if present
	NSRange range = NSMakeRange(0, [videos count]);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[tableView removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
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
				// insert new rows:
				NSRange range = NSMakeRange(0, [videos count]);
				NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
				[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
				//[tableView reloadData];
				//[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
				//[scrollView reflectScrolledClipView: [scrollView contentView]];
			});
		}];
	});
}

- (void)refreshWithWatchLater
{
	// remove current rows if present
	NSRange range = NSMakeRange(0, [videos count]);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[tableView removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
	[session watchLaterWithCompletion:^(NSArray *_videos, NSError *error) {
		videos = _videos;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			// insert new rows:
			NSRange range = NSMakeRange(0, [videos count]);
			NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
			[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
			//[tableView reloadData];
			//[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
			//[scrollView reflectScrolledClipView: [scrollView contentView]];
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
	// remove current rows if present
	NSRange range = NSMakeRange(0, [videos count]);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[tableView removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
	if (![[searchField stringValue] isEqualToString:@""])
	{
		[titleTextField setStringValue:[[NSString alloc] initWithFormat:@"Search - %@", [searchField stringValue]]];
		[session searchWithQuery:[searchField stringValue] completion:^(NSArray *_videos, NSError *error) {
			videos = _videos;
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				// insert new rows:
				NSRange range = NSMakeRange(0, [videos count]);
				NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
				[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
				//[tableView reloadData];
				//[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
				//[scrollView reflectScrolledClipView: [scrollView contentView]];
			});
		}];
	}
}

- (void)refreshWithMostPopular
{
	// remove current rows if present
	NSRange range = NSMakeRange(0, [videos count]);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[tableView removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideDown];
	[session mostPopularWithCompletion:^(NSArray *_videos, NSError *error) {
		videos = _videos;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			// insert new rows:
			NSRange range = NSMakeRange(0, [videos count]);
			NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
			[tableView insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideRight];
			//[tableView reloadData];
			//[[scrollView contentView] scrollToPoint: NSMakePoint(0, 0)];
			//[scrollView reflectScrolledClipView: [scrollView contentView]];
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
