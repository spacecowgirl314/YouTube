//
//  PSCYouTubeSession.m
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeSession.h"
#import "PSCYouTubeVideo.h"
#import "PSCYouTubeAuthenticator.h"
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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	NSMutableArray *channels = [NSMutableArray new];
	NSError *error;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/users/default/subscriptions?v=2&max-results=50&orderby=published"]];
	
	NSString *authorizationHeaderString = [[NSString alloc] initWithFormat:@"Bearer %@", [self authToken]];
	NSString *developerKeyHeaderString = [[NSString alloc] initWithFormat:@"key=%@", developerKey];
	
	[request setValue:authorizationHeaderString forHTTPHeaderField:@"Authorization"];
	[request setValue:developerKeyHeaderString forHTTPHeaderField:@"X-GData-Key"];
	
	NSError *connectionError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&connectionError];
	
	if (connectionError)
	{
		if ([connectionError code] == -1012)
		{
			// if it's our first time we can't do this, this is also dangerously recursive
			if([self authToken]!=nil)
			{
				NSLog(@"Your token has expired. Please request a new one.");
				NSLog(@"Client:%@", [[PSCYouTubeAuthenticator sharedAuthenticator] clientID]);
				[[PSCYouTubeAuthenticator sharedAuthenticator] reauthorize];
				[self subscriptionsWithCompletion:completion];
				//return;
			}
		}
		if ([connectionError code] == -1009)
		{
			NSLog(@"It appears you have no internet connection.");
		}
		NSLog(@"error: %@", [connectionError description]);
	}
	
	//NSLog(@"response: %@", [[NSString alloc] initWithData:data
	//											 encoding:NSUTF8StringEncoding]);
	
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
			[channel setChannelImage:[[NSImage alloc] initWithContentsOfURL:[channel thumbnailURL]]];
			[channel setUnreadCount:[NSNumber numberWithLong:[[entryElement child:@"unreadCount"] textAsInt]]];
			[channel setLastUpdated:nil]; // [[entryElement child:@"updated"] dateFromString];
			for (RXMLElement *linkElement in [entryElement children:@"link"])
			{
				if ([[linkElement attribute:@"rel"] isEqualToString:@"http://gdata.youtube.com/schemas/2007#user.uploads"]) {
					//&max-results=50
					NSString *urlString = [[NSString alloc] initWithFormat:@"%@&max-results=50", [linkElement attribute:@"href"]];
					[channel setMainURL:[NSURL URLWithString:urlString]];
				}
				if ([[linkElement attribute:@"rel"] isEqualToString:@"self"])
				{
					[channel setSubscriptionID:[NSURL URLWithString:[linkElement attribute:@"href"]]];
				}
				if ([[linkElement attribute:@"rel"] isEqualToString:@"alternate"])
				{
					[channel setBrowserURL:[NSURL URLWithString:[linkElement attribute:@"href"]]];
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
	});
}

- (void)unsubscribeWithChannel:(PSCYouTubeChannel*)channel completion:(PSCUnsubscribeCompletion)completion
{
	NSError *error;
	
	/*
	 DELETE /feeds/api/users/default/subscriptions/SUBSCRIPTION_ID HTTP/1.1
	 Host: gdata.youtube.com
	 Content-Type: application/atom+xml
	 Authorization: Bearer ACCESS_TOKEN
	 GData-Version: 2
	 X-GData-Key: key=DEVELOPER_KEY
	 */
	
	//NSString *urlString = [[NSString alloc] initWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/subscriptions/%@?v=2", [channel subscriptionID]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[channel subscriptionID]];//[NSURL URLWithString:urlString]];
	
	NSString *authorizationHeaderString = [[NSString alloc] initWithFormat:@"Bearer %@", [self authToken]];
	NSString *developerKeyHeaderString = [[NSString alloc] initWithFormat:@"key=%@", developerKey];
	
	[request setHTTPMethod:@"DELETE"];
	[request setValue:authorizationHeaderString forHTTPHeaderField:@"Authorization"];
	[request setValue:developerKeyHeaderString forHTTPHeaderField:@"X-GData-Key"];
	//[request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
	
	NSError *connectionError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&connectionError];
	
	NSLog(@"response: %@", [[NSString alloc] initWithData:data
												 encoding:NSUTF8StringEncoding]);
	
	if (connectionError)
	{
		if ([connectionError code] == -1012)
		{
			// if it's our first time we can't do this, this is also dangerously recursive
			if([self authToken]!=nil)
			{
				NSLog(@"Your token has expired. Please request a new one.");
				NSLog(@"Client:%@", [[PSCYouTubeAuthenticator sharedAuthenticator] clientID]);
				[[PSCYouTubeAuthenticator sharedAuthenticator] reauthorize];
				[self unsubscribeWithChannel:channel completion:completion];
				return;
			}
		}
		if ([connectionError code] == -1009)
		{
			NSLog(@"It appears you have no internet connection.");
		}
		NSLog(@"error: %@", [connectionError description]);
	}
		
	completion(error);
}

- (void)videosWithURL:(NSURL*)url completion:(PSCVideosRequestCompletion)completion
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	NSMutableArray *videos = [NSMutableArray new];
	NSError *error;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSString *authorizationHeaderString = [[NSString alloc] initWithFormat:@"Bearer %@", [self authToken]];
	NSString *developerKeyHeaderString = [[NSString alloc] initWithFormat:@"key=%@", developerKey];
	
		
	[request setValue:authorizationHeaderString forHTTPHeaderField:@"Authorization"];
	[request setValue:developerKeyHeaderString forHTTPHeaderField:@"X-GData-Key"];
	
	NSError *connectionError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&connectionError];
	
	if (connectionError)
	{
		if ([connectionError code] == -1012)
		{
			NSLog(@"Your token has expired. Please request a new one.");
			NSLog(@"Client:%@", [[PSCYouTubeAuthenticator sharedAuthenticator] clientID]);
			[[PSCYouTubeAuthenticator sharedAuthenticator] reauthorize];
			[self subscriptionsWithCompletion:completion];
			return;
		}
		if ([connectionError code] == -1009)
		{
			NSLog(@"It appears you have no internet connection.");
		}
		NSLog(@"error: %@", [connectionError description]);
	}
	
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
	});
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
