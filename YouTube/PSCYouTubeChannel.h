//
//  PSCYouTubeChannel.h
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCYouTubeChannel : NSObject

@property NSString *displayName; // tag yt:username attribute display
@property NSURL *thumbnailURL; // tag media:thumbnail attribute url
@property NSNumber *unreadCount; // tag yt:unreadCount
@property NSDate *lastUpdated; // tag updated
@property NSURL *mainURL; // tag link rel="http://gdata.youtube.com/schemas/2007#user.uploads" attribute href
@property NSImage *channelImage; // downloaded thumbnailURL
@property NSURL *subscriptionID; // tag link rel="self" attribute href
@property NSURL *browserURL; // tag link rel="alternate" attribute href

@end
