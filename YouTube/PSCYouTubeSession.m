//
//  PSCYouTubeSession.m
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeSession.h"
#import "PSCYouTubeVideo.h"
#import "RXMLElement.h"

@implementation PSCYouTubeSession
@synthesize developerKey;
@synthesize userName;

/*- (id)init
{
	userName = @"Test";
	
	return self;
}*/

+ (id)sharedSession
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString*)authToken {
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
}

- (void)subscriptionsWithCompletion:(PSCSubscriptionsRequestCompletion)completion
{
	NSMutableArray *channels = [NSMutableArray new];
	NSError *error;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/users/default/subscriptions?v=2&max-results=50&orderby=published"]];
	
	NSString *authorizationHeaderString = [[NSString alloc] initWithFormat:@"Bearer %@", [self authToken]];
	NSString *developerKeyHeaderString = [[NSString alloc] initWithFormat:@"key=%@", developerKey];
	
	[request setValue:authorizationHeaderString forHTTPHeaderField:@"Authorization"];
	[request setValue:developerKeyHeaderString forHTTPHeaderField:@"X-GData-Key"];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	/*NSLog(@"response: %@", [[NSString alloc] initWithData:data
												 encoding:NSUTF8StringEncoding]);*/
	
	RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
	//RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/users/codingguru/subscriptions?v=2&max-results=50&orderby=published"]];
	
	if ([rootXML isValid])
	{
		[self setUserName:[[[rootXML child:@"author"] child:@"name"] text]];
		[rootXML iterate:@"entry" usingBlock:^(RXMLElement *entryElement)
		{
			//NSLog(@"text:%@\n", [entryElement text]);
			PSCYouTubeChannel *channel = [PSCYouTubeChannel new];
			//[entryElement child:@"yt:username"]
			[channel setDisplayName:[[entryElement child:@"username"] attribute:@"display"]];
			[channel setThumbnailURL:[NSURL URLWithString:[[entryElement child:@"thumbnail"] attribute:@"url"]]];
			// [entryElement child:@"yt:unreadCount"]
			[channel setUnreadCount:[NSNumber numberWithInt:[[entryElement child:@"unreadCount"] textAsInt]]];
			[channel setLastUpdated:nil]; // [[entryElement child:@"updated"] dateFromString];
			for (RXMLElement *linkElement in [entryElement children:@"link"])
			{
				if ([[linkElement attribute:@"rel"] isEqualToString:@"http://gdata.youtube.com/schemas/2007#user.uploads"]) {
					//&max-results=50
					NSString *urlString = [[NSString alloc] initWithFormat:@"%@&max-results=50", [linkElement attribute:@"href"]];
					[channel setMainURL:[NSURL URLWithString:urlString]];
				}
			}
			[channels addObject:channel];
		}];
	}
	else
	{
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"YouTube is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
	}
	
	completion(channels, error);
}

- (void)videosWithURL:(NSURL*)url completion:(PSCVideosRequestCompletion)completion
{
	NSMutableArray *videos = [NSMutableArray new];
	NSError *error;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSString *authorizationHeaderString = [[NSString alloc] initWithFormat:@"Bearer %@", [self authToken]];
	NSString *developerKeyHeaderString = [[NSString alloc] initWithFormat:@"key=%@", developerKey];
	
	[request setValue:authorizationHeaderString forHTTPHeaderField:@"Authorization"];
	[request setValue:developerKeyHeaderString forHTTPHeaderField:@"X-GData-Key"];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	/*NSLog(@"response: %@", [[NSString alloc] initWithData:data
	 encoding:NSUTF8StringEncoding]);*/
	
	RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
	
	if ([rootXML isValid])
	{
		[rootXML iterate:@"entry" usingBlock:^(RXMLElement *entryElement)
		 {
			 PSCYouTubeVideo *video = [PSCYouTubeVideo new];
			 RXMLElement *groupElement = [entryElement child:@"group"];
			 
			 [video setTitle:[[entryElement child:@"title"] text]];
			 for (RXMLElement *thumnailElement in [groupElement children:@"thumbnail"])
			 {
				 if ([[thumnailElement attribute:@"name"] isEqualToString:@"hqdefault"])
				 {
					 [video setThumbnailURL:[NSURL URLWithString:[thumnailElement attribute:@"url"]]];
				 }
			 }
			 for (RXMLElement *linkElement in [entryElement children:@"link"])
			 {
				 if ([[linkElement attribute:@"rel"] isEqualToString:@"alternate"])
				 {
					 [video setSiteURL:[NSURL URLWithString:[linkElement attribute:@"href"]]];
				 }
			 }
			 
			 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			 // See http://www.faqs.org/rfcs/rfc3339.html
			 // help from https://github.com/mwaterfall/MWFeedParser/blob/master/Classes/NSDate%2BInternetDateTime.m
			 // 2012-09-07T02:17:50.000Z
			 [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
			 NSDate *date = [dateFormatter dateFromString: [[entryElement child:@"published"] text]];
			 //NSLog(@"date:%@ with:%@", [myDate description], [[entryElement child:@"published"] text]);
			 [video setPublishedDate:date];
			 
			 [video setDescription:[[groupElement child:@"description"] text]];
			 [video setViewCount:[NSNumber numberWithInt:[[[entryElement child:@"statistics"] attribute:@"viewCount"] intValue]]];
			 [video setVideoURL:[NSURL URLWithString:[[entryElement child:@"content"] attribute:@"src"]]];
			 [video setUploader:[[[entryElement child:@"group"] child:@"credit"] attribute:@"display"]];
			 
			 [videos addObject:video];
		 }];
	}
	else
	{
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"YouTube is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
	}
	
	completion(videos, error);
}

- (void)subscriptionWithChannel:(PSCYouTubeChannel*)channel completion:(PSCVideosRequestCompletion)completion
{
	[self videosWithURL:[channel mainURL] completion:completion];
}

- (void)watchLaterWithCompletion:(PSCVideosRequestCompletion)completion
{
	// https://developers.google.com/youtube/2.0/developers_guide_protocol_playlists#Retrieving_watch_later_playlist
	// https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2
	
	[self videosWithURL:[NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2"] completion:completion];
}

- (void)searchWithQuery:(NSString*)query completion:(PSCVideosRequestCompletion)completion
{
	// duplicate of subscriptionWithChannel with minor changes
	NSString *escapedQuery = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *searchURLString = [[NSString alloc] initWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&orderby=relevance&max-results=50&v=2", escapedQuery];
	
	[self videosWithURL:[NSURL URLWithString:searchURLString] completion:completion];
}

- (void)mostPopularWithCompletion:(PSCVideosRequestCompletion)completion
{
	// test of refactor
	[self videosWithURL:[NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/standardfeeds/most_popular?v=2"] completion:completion];
}

@end
