//
//  BasePictureProtocol.h
//  Finger
//
//  Created by Ivan Dilchovski on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



@protocol BasePictureProtocol

- (id) initWithPath:(NSString*) filePath;						//Load image from specific file path;
- (void) setFilePath:(NSString*) newPath;						//Should be implemented to force image reload!

@end
