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
				NSLog([[NSString stringWithString:@"DEBUG_TOUCH:"] stringByAppendingString:message]);
		} break;
			
		case DEBUG_TOUCH_MOVE:
		{
			if(DEBUG_TOUCH_MOVE_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_TOUCH_MOVE:"] stringByAppendingString:message]);
		} break;

		case DEBUG_LISTENER:
		{
			if(DEBUG_LISTENER_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_LISTENER:"] stringByAppendingString:message]);
		} break;
			
		case DEBUG_LISTENER_MOVE:
		{
			if(DEBUG_LISTENER_MOVE_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_LISTENER_MOVE:"] stringByAppendingString:message]);
		} break;

		case DEBUG_GENERAL:
		{
			if(DEBUG_GENERAL_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_GENERAL:"] stringByAppendingString:message]);
		} break;
			
		case DEBUG_RENDER:
		{
			if(DEBUG_RENDER_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_RENDER:"] stringByAppendingString:message]);
		} break;
		case DEBUG_PHYSICS:
		{
			if(DEBUG_PHYSICS_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_PHYSICS:"] stringByAppendingString:message]);
		} break;
		case DEBUG_ERROR:
		{
			if(DEBUG_ERROR_STATE)
				NSLog([[NSString stringWithString:@"DEBUG_ERROR:"] stringByAppendingString:message]);
		} break;
	}
}
@end
