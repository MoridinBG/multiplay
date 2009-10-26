//
//  PictureAlbum.m
//  Finger
//
//  Created by Ivan Dilchovski on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PictureGallery.h"


@implementation PictureGallery

- (id) initWithPicturesInDirectory:(NSString*)directoryPath
{
	if(self = [super init])
	{
		pictures = [[NSMutableArray alloc] initWithCapacity:15];
		NSError *error;
		NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
		
		for(NSString *filePath in files)
		{
			[Logger logMessage:[NSString stringWithFormat:@"Loading file %s", 
								[[directoryPath stringByAppendingString:filePath] cStringUsingEncoding:NSUTF8StringEncoding]] ofType:DEBUG_GENERAL];

			BasePicture *image = [[BasePicture alloc] initWithPath:[directoryPath stringByAppendingString:filePath]];
			if(!image)
			{
				[Logger logMessage:[NSString stringWithFormat:@"Skipping non PNG file %s", [filePath cStringUsingEncoding:NSUTF8StringEncoding]] ofType:DEBUG_GENERAL];
				continue;
			}
			[pictures addObject:image];
		}
	}
	
	return self;
}
@end
