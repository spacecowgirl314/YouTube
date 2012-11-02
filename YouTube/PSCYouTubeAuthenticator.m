//
//  PSCYouTubeAuthenticator.m
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeAuthenticator.h"
#import "HTTPServer.h"

@implementation PSCYouTubeAuthenticator

- (id)init {
	// server from http://www.cocoawithlove.com/2009/07/simple-extensible-http-server-in-cocoa.html
	// star the authentication server to grab the token
	[[HTTPServer sharedHTTPServer] start];
	
	return self;
}

- (NSURL*)URLToAuthorize
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://accounts.google.com/o/oauth2/auth?client_id=%@&redirect_uri=%@&scope=https://gdata.youtube.com&response_type=code&access_type=offline", _clientID, _redirectURL];
	return [NSURL URLWithString:urlString];
}

@end
