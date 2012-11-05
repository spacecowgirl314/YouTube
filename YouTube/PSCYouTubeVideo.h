//
//  PSCYouTubeVideo.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCYouTubeVideo : NSObject

@property NSString *title; // title tag
@property NSURL *thumbnailURL; // thumbnail tag ns media with name = "hqdefault" for retina, "mqdefault" for non, inside group ns media tag
@property NSString *description; // description tag ns media, inside group ns media tag
@property NSNumber *viewCount; // statistics tag, attribute viewCount
@property NSURL *videoURL; // content tag

@end