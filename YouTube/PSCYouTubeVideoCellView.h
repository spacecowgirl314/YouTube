//
//  PSCYouTubeVideoCellView.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface PSCYouTubeVideoCellView : NSTableCellView
{
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *viewCountField;
	IBOutlet NSTextField *timeAgoField;
	IBOutlet NSTextField *descriptionField;
	IBOutlet NSImageView *thumbnailView;
	IBOutlet WebView *videoView;
}

@property IBOutlet NSTextField *titleField;
@property IBOutlet NSTextField *viewCountField;
@property IBOutlet NSTextField *timeAgoField;
@property IBOutlet NSTextField *descriptionField;
@property IBOutlet NSImageView *thumbnailView;
@property IBOutlet WebView *videoView;

@end
