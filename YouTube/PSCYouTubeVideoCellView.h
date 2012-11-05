//
//  PSCYouTubeVideoCellView.h
//  YouTube
//
//  Created by Chloe Stars on 11/5/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSCYouTubeVideoCellView : NSTableCellView
{
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *viewCountField;
	IBOutlet NSTextField *descriptionField;
	IBOutlet NSImageView *thumbnailView;
}

@property IBOutlet NSTextField *titleField;
@property IBOutlet NSTextField *viewCountField;
@property IBOutlet NSTextField *descriptionField;
@property IBOutlet NSImageView *thumbnailView;

@end
