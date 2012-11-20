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
typedef void (^PSCVideosRequestCompletion)(NSArray * videos, NSError * error);
typedef void (^PSCUnsubscribeCompletion)(NSError * error);

+ (id)sharedSession;
- (void)subscriptionsWithCompletion:(PSCSubscriptionsRequestCompletion)completion;
- (void)subscriptionWithChannel:(PSCYouTubeChannel*)channel completion:(PSCVideosRequestCompletion)completion;
- (void)unsubscribeWithChannel:(PSCYouTubeChannel*)channel completion:(PSCUnsubscribeCompletion)completion;
- (void)watchLaterWithCompletion:(PSCVideosRequestCompletion)completion;
- (void)searchWithQuery:(NSString*)query completion:(PSCVideosRequestCompletion)completion;
- (void)mostPopularWithCompletion:(PSCVideosRequestCompletion)completion;

@property NSString *developerKey;
@property NSString *userName;

@end
