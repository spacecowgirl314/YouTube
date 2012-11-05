//
//  PSCYouTubeAuthenticator.h
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCYouTubeAuthenticator : NSObject

- (BOOL)isAuthenticated;
- (NSURL*)URLToAuthorize;

@property NSString *clientID;
@property NSString *clientSecret;
@property NSString *redirectURL;

@end
