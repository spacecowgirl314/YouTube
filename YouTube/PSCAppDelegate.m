//
//  PSCAppDelegate.m
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCAppDelegate.h"
#import "PSCYouTubeSession.h"

@implementation PSCAppDelegate

- (id)init
{
	// reigster url scheme. also must be in init to be called when launched
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	//[self authenticate];
}

#pragma mark Authentication

- (void)authenticate
{
	authenticator = [PSCYouTubeAuthenticator sharedAuthenticator];
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
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSURL *URL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"received query %@", [URL host]);
}

@end
