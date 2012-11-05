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
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(receivedToken:)
	 name:@"ReceivedToken"
	 object:nil];
	
	// server from http://www.cocoawithlove.com/2009/07/simple-extensible-http-server-in-cocoa.html
	// star the authentication server to grab the token
	[[HTTPServer sharedHTTPServer] start];
	
	return self;
}

- (BOOL)isAuthenticated
{
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"token"] != nil)
	{
		return YES;
	}
	else {
		return NO;
	}
}

- (NSURL*)URLToAuthorize
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://accounts.google.com/o/oauth2/auth?client_id=%@&redirect_uri=%@&scope=https://gdata.youtube.com&response_type=code&access_type=offline", _clientID, _redirectURL];
	return [NSURL URLWithString:urlString];
}

- (void)receivedToken:(NSNotification*)notification
{
	NSString *token = [notification object];
	
	// exchange authorization code for refresh and access tokens https://accounts.google.com/o/oauth2/token
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"]];
	
	NSString *post = [NSString stringWithFormat:@"&code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code",token,_clientID,_clientSecret,_redirectURL];
	
	//2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	
	//You need to send the actual length of your data. Calculate the length of the post string.
	
	NSString *postLength = [NSString stringWithFormat:@"%ld",[postData length]];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
	[request setHTTPBody:postData];
	
	NSError *error;
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSLog(@"error: %@", [error description]);
	
	NSLog(@"response: %@", [[NSString alloc] initWithData:data
												 encoding:NSUTF8StringEncoding]);
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
	NSLog(@"error: %@", [error description]);
	
	NSString *authorizationToken = [dictionary objectForKey:@"access_token"];
	
	// set authorization token
	NSLog(@"authorization:%@", authorizationToken);
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (token) {
		[defaults setObject:authorizationToken forKey:@"access_token"];
	} else {
		[defaults removeObjectForKey:@"access_token"];
	}
	[defaults synchronize];
}

- (void) dealloc
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
