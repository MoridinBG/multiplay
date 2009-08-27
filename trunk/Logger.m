//
//  Logger.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "Logger.h"


@implementation Logger
+ (void) logMessage:(NSString*)message ofType:(DebugState)type
{
	switch(type)
	{
		case DEBUG_TOUCH:
		{
			if(DEBUG_TOUCH_STATE)
				NSLog(message);
		} break;
			
		case DEBUG_TOUCH_MOVE:
		{
			if(DEBUG_TOUCH_MOVE_STATE)
				NSLog(message);
		} break;

		case DEBUG_LISTENER:
		{
			if(DEBUG_LISTENER_STATE)
				NSLog(message);
		} break;
			
		case DEBUG_LISTENER_MOVE:
		{
			if(DEBUG_LISTENER_MOVE_STATE)
				NSLog(message);
		} break;

		case DEBUG_GENERAL:
		{
			if(DEBUG_GENERAL_STATE)
				NSLog(message);
		} break;
			
		case DEBUG_RENDER:
		{
			if(DEBUG_RENDER_STATE)
				NSLog(message);
		} break;
	}
}
@end
