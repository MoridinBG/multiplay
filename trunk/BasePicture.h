//
//  BasePicture.h
//  Finger
//
//
//	Abstract class for implementation of image loading and manipulation
//
//  Created by Ivan Dilchovski on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <png.h>

#import "Logger.h"
#import "BasePictureProtocol.h"
#import "InteractiveObject.h"


@interface BasePicture : InteractiveObject <BasePictureProtocol>
{	
	CGSize pixelSize;
	CGSize oglSize;
	GLuint texName;
	NSString *filePath;
}
@property CGSize pixelSize;
@property CGSize oglSize;
@property GLuint texName;
@property (copy) NSString *filePath;			//Copy photo or assigner could change it!

- (id) initWithPath:(NSString*) filePath;
- (unsigned char*) loadPng;

@end
