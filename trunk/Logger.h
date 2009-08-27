//
//  Logger.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "consts.h"

@interface Logger : NSObject 
{
}
+ (void) logMessage:(NSString*) message ofType:(DebugState) type;
@end
