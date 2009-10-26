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
	NSTimer *timer;
	NSMutableArray *shownPictures;
}
- (void)showPicture:(NSTimer*)theTimer;
- (id) initWithPicturesInDirectory:(NSString*)directoryPath;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
