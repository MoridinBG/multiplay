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
#import "BasePictureProtocol.h"

@interface BasePicture : NSObject <BasePictureProtocol>
{
	NSRect boundingBox;
	CGPoint position;
	
	float angle;
	
	NSString *filePath;

}
@property (copy) NSString *filePath;			//Copy photo or assigner could change it!
@property float angle;
@property NSRect boundingBox;
@property CGPoint position;

@end
