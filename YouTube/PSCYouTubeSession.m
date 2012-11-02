//
//  PSCYouTubeSession.m
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeSession.h"
#import "PSCYouTubeChannel.h"
#import "RXMLElement.h"

@implementation PSCYouTubeSession
@synthesize authToken = _authToken;

- (NSString*)authToken {
	if (!_authToken) {
		_authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"];
		NSLog(@"Read API Key %@", _authToken);
	}
	return _authToken;
}

- (void)subscriptionsWithCompletion:(PSCSubscriptionRequestCompletion)completion
{
	NSMutableArray *channels = [NSMutableArray new];
	NSError *error;
	
	// when ready for primetime use https://gdata.youtube.com/feeds/api/users/default/subscriptions?v=2
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/users/codingguru/subscriptions?v=2&max-results=50&orderby=published"]];
	
	if ([rootXML isValid]) {
		[rootXML iterate:@"entry" usingBlock:^(RXMLElement *entryElement) {
			//NSLog(@"text:%@\n", [entryElement text]);
			PSCYouTubeChannel *channel = [PSCYouTubeChannel new];
			//[entryElement child:@"yt:username"]
			[channel setDisplayName:[[entryElement child:@"username"] attribute:@"display"]];
			[channel setThumbnailURL:[NSURL URLWithString:[[entryElement child:@"thumbnail"] attribute:@"url"]]];
			// [entryElement child:@"yt:unreadCount"]
			[channel setUnreadCount:[NSNumber numberWithInt:[[entryElement child:@"unreadCount"] textAsInt]]];
			[channel setLastUpdated:nil]; // [[entryElement child:@"updated"] dateFromString];
			[channels addObject:channel];
		}];
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"YouTube is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
	}
	
	completion(channels, error);
}

@end
