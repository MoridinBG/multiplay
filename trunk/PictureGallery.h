//
//  PictureAlbum.h
//  Finger
//
//
//  Created by Ivan Dilchovski on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "BasePicture.h"
#import "Logger.h"


@interface PictureGallery : EffectProvider <EffectProviderProtocol>
{

	NSMutableArray *pictures;
}

- (id) initWithPicturesInDirectory:(NSString*)directoryPath;
@end
