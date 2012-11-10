//
//  PSCYouTubeSession.h
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSCYouTubeChannel.h"

@interface PSCYouTubeSession : NSObject

typedef void (^PSCSubscriptionsRequestCompletion)(NSArray * channels, NSError * error);
typedef void (^PSCChannelRequestCompletion)(NSArray * videos, NSError * error);

- (void)subscriptionsWithCompletion:(PSCSubscriptionsRequestCompletion)completion;
- (void)subscriptionWithChannel:(PSCYouTubeChannel*)channel completion:(PSCChannelRequestCompletion)completion;
- (void)watchLaterWithCompletion:(PSCChannelRequestCompletion)completion;
- (void)searchWithQuery:(NSString*)query completion:(PSCChannelRequestCompletion)completion;
- (void)mostPopularWithCompletion:(PSCChannelRequestCompletion)completion;

@property NSString *developerKey;

@end
