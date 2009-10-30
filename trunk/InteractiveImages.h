//
//  InteractiveImages.h
//  Finger
//
//  Created by Ivan Dilchovski on 10/22/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PictureGallery.h"

@interface InteractiveImages : PictureGallery
{
	NSMutableArray *shownPictures;
	NSMutableArray *disappearingPictures;
	NSMutableArray *deadPictures;
	
	NSTimer *pictureCreator;
	NSMutableArray *deathTimers;
}
- (id) initWithPicturesInDirectory:(NSString*)directoryPath;

- (void) processTouches:(TouchEvent*)event;
- (void) render;

- (void) showPicture:(NSTimer*) theTimer;
- (void) removePicture:(NSTimer*) theTimer;
@end
