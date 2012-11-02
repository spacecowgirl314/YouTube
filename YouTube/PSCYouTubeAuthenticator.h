//
//  PSCYouTubeAuthenticator.h
//  YouTube
//
//  Created by Chloe Stars on 11/2/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCYouTubeAuthenticator : NSObject

- (NSURL*)URLToAuthorize;

@property NSString *clientID;
@property NSString *redirectURL;

@end
