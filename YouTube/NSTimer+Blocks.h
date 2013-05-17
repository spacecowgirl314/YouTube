//
//  NSTimer+Blocks.h
//  Sunlight
//
//  Created by Chloe Stars on 10/14/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TIMER_BLOCK__)(NSTimer*);

@interface NSTimer (Blocks)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
									  block:(TIMER_BLOCK__)block repeats:(BOOL)repeats;

@end