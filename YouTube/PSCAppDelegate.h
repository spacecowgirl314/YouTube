//
//  PSCAppDelegate.h
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSCYouTubeAuthenticator.h"
#import "PSCYouTubeChannelDataSource.h"

@interface PSCAppDelegate : NSObject <NSApplicationDelegate>
{
	PSCYouTubeAuthenticator *authenticator;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) PSCYouTubeChannelDataSource *channelDataSource;

@end
