//
//  PSCPlayerView.m
//  YouTube
//
//  Created by Chloe Stars on 11/22/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "PSCPlayerView.h"
#import "NSView+Fade.h"
#import "NSTimer+Blocks.h"

static void *PSCPlayerLayerReadyForDisplay = &PSCPlayerLayerReadyForDisplay;
static void *PSCPlayerRateChange = &PSCPlayerRateChange;
static void *PSCPlayerViewBoundsChanged = &PSCPlayerViewBoundsChanged;

@implementation PSCPlayerView
@synthesize playerLayer;
@synthesize block;
@synthesize barView;
@synthesize playPauseButton;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
	[self setWantsLayer:YES];
	[[self layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
	player = [[AVPlayer alloc] init];
	
	// setup player bar
	//[barView setAlphaValue:0.5];
	
	// setup player
	AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	[newPlayerLayer setFrame:[[self layer] bounds]];
	[newPlayerLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
	//[[self layer] addSublayer:newPlayerLayer];
	[[self layer] insertSublayer:newPlayerLayer below:[barView layer]];
	[self setPlayerLayer:newPlayerLayer];
	
	// setup mouse in out
	NSTrackingAreaOptions trackingOptions =
	NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways;
	/*NSTrackingArea *myTrackingArea = [[NSTrackingArea alloc]
	 initWithRect: [imageView bounds] // in our case track the entire view
	 options: trackingOptions
	 owner: self
	 userInfo: nil];*/
	trackingArea = [[NSTrackingArea alloc]
					initWithRect: [self bounds] // in our case track the entire view
					options: trackingOptions
					owner: self
					userInfo: nil];
	[self addTrackingArea: trackingArea];
	[self addObserver:self forKeyPath:@"self.frame" options:NSKeyValueObservingOptionNew context:PSCPlayerViewBoundsChanged];
	[self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:PSCPlayerRateChange];
	
	//[timeSlider setContinuous:YES];
	[timeSlider setAction:@selector(didSliderMove:)];
}

- (void)didSliderMove:(id)sender
{
	[player seekToTime:CMTimeMakeWithSeconds([timeSlider doubleValue], 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)setPlayerItem:(AVPlayerItem*)playerItem completion:(void (^)())readyBlock
{
	block = readyBlock;
	[player replaceCurrentItemWithPlayerItem:playerItem];
	[self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PSCPlayerLayerReadyForDisplay];
	
	// setup play position
	[timeSlider setMaxValue:CMTimeGetSeconds([[playerItem asset] duration])];
	[player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
		[timeSlider setDoubleValue:CMTimeGetSeconds(time)];
	}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == PSCPlayerLayerReadyForDisplay)
	{
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES)
		{
			// The AVPlayerLayer is ready for display.
			block();
		}
	}
	if (context == PSCPlayerViewBoundsChanged)
	{
		//NSLog(@"change:%@", [change description]);
		//if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES)
		//{
			[self removeTrackingArea:trackingArea];
			NSTrackingAreaOptions trackingOptions =
			NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways;
			trackingArea = [[NSTrackingArea alloc]
							initWithRect: [self bounds] // in our case track the entire view
							options: trackingOptions
							owner: self
							userInfo: nil];
			[self addTrackingArea: trackingArea];
		//}
	}
	if (context == PSCPlayerRateChange)
	{
		if ([[change objectForKey:NSKeyValueChangeNewKey] floatValue] == 0.0)
		{
			[playPauseButton setImage:[NSImage imageNamed:@"play"]];
		}
		else if ([[change objectForKey:NSKeyValueChangeNewKey] floatValue] > 0.0)
		{
			[playPauseButton setImage:[NSImage imageNamed:@"pause"]];
		}
	}
}

- (void)play
{
	[player play];
}

- (IBAction)toggleState:(id)sender
{
	if ([player rate] != 1.f)
	{
		//if ([self currentTime] == [self duration])
		//	[self setCurrentTime:0.f];
		[player play];
	}
	else
	{
		[player pause];
	}
}

- (void) mouseEntered:(NSEvent*)theEvent {
    // Mouse entered tracking area.
	//[barView setHidden:NO withFade:YES blocking:YES];
	[barView setHidden:NO];
	/*trackingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
		//[barView setHidden:YES withFade:YES blocking:YES];
		[barView setHidden:YES];
		//[trackingTimer setFireDate:[NSDate distantFuture]];
	} repeats:NO];*/
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	// if mouse inside barView then don't do this
	//[barView setHidden:NO withFade:YES blocking:YES];
	//[barView setHidden:NO];
	// hide again after some time
	/*trackingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
		//[barView setHidden:YES withFade:YES blocking:YES];
		[barView setHidden:YES];
		//[trackingTimer setFireDate:[NSDate distantFuture]];
	} repeats:NO];*/
}

- (void) mouseExited:(NSEvent*)theEvent {
    // Mouse exited tracking area.
	//[barView setHidden:YES withFade:YES blocking:YES];
	[barView setHidden:YES];
	// get rid of timers
	//[trackingTimer invalidate];
}

/*-(void) hideBarView
{
	// 这段代码是不能重进的，否则会不停的hidecursor
	if ([self alphaValue] > (1-0.05)) {
		// 得到鼠标在这个window的坐标
		NSPoint pos = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
		
		// 如果不在这个View的话，那么就隐藏自己
		// if HideTitlebar is ON, ignore the titlebar area when hiding the cursor
		if ((!NSPointInRect([self convertPoint:pos fromView:nil], barView.bounds))) {
			[self.animator setAlphaValue:0];
			
			// 如果是全屏模式也要隐藏鼠标
			if ([dispView isInFullScreenMode]) {
				// 这里的[self window]不是成员的那个window，而是全屏后self的新window
				if ([[self window] isKeyWindow] && NSPointInRect([NSEvent mouseLocation], [[self window] frame])) {
					// 如果不是key window的话，就不隐藏鼠标
					[NSCursor hide];
				}
			} else {
				// 不是全屏的话，隐藏resizeindicator
				// 全屏的话不管
				[rzIndicator.animator setAlphaValue:0];
				// 这里应该判断kUDKeyHideTitlebar的，但是由于这里是要隐藏title
				// 因此多次将AlphaValue设置为0也不会有坏影响
				[title.animator setAlphaValue:0];
			}
		}
	}
}*/

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
