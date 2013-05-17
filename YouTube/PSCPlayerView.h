//
//  PSCPlayerView.h
//  YouTube
//
//  Created by Chloe Stars on 11/22/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface PSCPlayerView : NSView
{
	AVPlayer *player;
	IBOutlet NSView *barView;
	IBOutlet NSButton *playPauseButton;
	IBOutlet NSSlider *timeSlider;
	@private
	AVPlayerLayer *playerLayer;
	NSTrackingArea *trackingArea;
	NSTimer *trackingTimer;
	NSWindow *popOutWindow;
}

- (void)setPlayerItem:(AVPlayerItem*)playerItem completion:(void (^)())readyBlock;
- (void)play;

@property (copy) void (^block)();
@property AVPlayerLayer *playerLayer;
@property IBOutlet NSView *barView;
@property IBOutlet NSButton *playPauseButton;

@end
