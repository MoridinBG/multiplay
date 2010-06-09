//
//  GlobalFunctions.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <mach/mach_time.h>

#import "consts.h"

@interface GlobalFunctions : NSObject
{
}

#pragma mark Geometry
+ (CGPoint) findEndPointForStart:(CGPoint)start withLength:(float)length atAngle:(float)angle;
+ (float) lengthBetweenPoint:(CGPoint)start  andPoint:(CGPoint)end;
+ (float) findAngleBetweenPoint:(CGPoint) start andPoint:(CGPoint)end;

+ (char) isPoint:(CGPoint)point toTheLeftOfLineBetween:(CGPoint)point1 and:(CGPoint)point2;

+ (CGPoint) findPointBetweenPoint:(CGPoint)pointA andPoint:(CGPoint)pointB;
#pragma mark -

#pragma mark Time
+ (double) substractStartTime:(uint64_t)startTime fromEndTime:(uint64_t)endTime;
#pragma mark -

#pragma mark Graphics
+ (GLuint) getTextureFromImage:(CGImageRef)image;
+ (CGImageRef) getCGImageAtPath:(NSString*)filePath;
#pragma mark -
@end