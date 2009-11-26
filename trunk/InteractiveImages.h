//
//  InteractiveImages.h
//  Finger
//
//  Created by Ivan Dilchovski on 10/22/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#define PICTURE_SHOW_TIME_FACTOR 400
#define PICTURE_REMOVE_TIME_FACTOR 600

#import <Cocoa/Cocoa.h>
#import "PictureGallery.h"

@interface InteractiveImages : PictureGallery
{
	NSMutableArray *shownPictures;
	NSMutableArray *disappearingPictures;
	NSMutableArray *deadPictures;
	
	NSTimer *pictureCreator;
}
- (id) initWithPicturesInDirectory:(NSString*)directoryPath;

- (void) processTouches:(TouchEvent*)event;
- (void) render;

- (void) showPicture:(NSTimer*) theTimer;
- (void) removePicture:(NSTimer*) theTimer;
@end
