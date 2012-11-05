//
//  PSCYouTubeTokenResponse.m
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCYouTubeTokenResponse.h"

@implementation PSCYouTubeTokenResponse

//
// load
//
// Implementing the load method and invoking
// [HTTPResponseHandler registerHandler:self] causes HTTPResponseHandler
// to register this class in the list of registered HTTP response handlers.
//
+ (void)load
{
	[HTTPResponseHandler registerHandler:self];
}

//
// canHandleRequest:method:url:headerFields:
//
// Class method to determine if the response handler class can handle
// a given request.
//
// Parameters:
//    aRequest - the request
//    requestMethod - the request method
//    requestURL - the request URL
//    requestHeaderFields - the request headers
//
// returns YES (if the handler can handle the request), NO (otherwise)
//
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
				  method:(NSString *)requestMethod
					 url:(NSURL *)requestURL
			headerFields:(NSDictionary *)requestHeaderFields
{
	NSString *url = [requestURL absoluteString];
	NSRange tkIdRange = [url rangeOfString:@"?code="];
	if (tkIdRange.location != NSNotFound) {
		NSString *token = [url substringFromIndex:NSMaxRange(tkIdRange)];
		// send token back to the authenticator
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"ReceivedToken"
		 object:token];
		
		return YES;
	}
	else {
		return NO;
	}
}

@end
