//
//  PSCYouTubeSession.h
//  YouTube
//
//  Created by Chloe Stars on 11/1/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCYouTubeSession : NSObject

typedef void (^PSCSubscriptionRequestCompletion)(NSArray * channels, NSError * error);

@property (assign) NSString *authToken;

- (void)subscriptionsWithCompletion:(PSCSubscriptionRequestCompletion)completion;

@end
