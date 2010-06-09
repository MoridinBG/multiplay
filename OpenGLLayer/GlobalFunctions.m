//
//  GlobalFunctions.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GlobalFunctions.h"

@implementation GlobalFunctions

#pragma mark Geometry
+ (CGPoint) findEndPointForStart:(CGPoint)start withLength:(float)length atAngle:(float)angle
{
	CGPoint end;
	
	while(angle > 360)
		angle -= 360;
	
	float xDiff = 1;
	float yDiff = 1;

	if(angle <= 180)
	{
		if(angle >= 90)
		{
			xDiff = -1;
//			yDiff = -1;
		}
		
		float sine = sin(angle * DEG2RAD);
		yDiff *= (sine * length);
		xDiff *= sqrt(pow(length, 2) - pow(yDiff, 2));
		
		end = CGPointMake(start.x + xDiff, 
						  start.y + yDiff);
	} else 
	{
		yDiff = -1;
		if(angle >= 270)
		{
			xDiff = -1;
			yDiff = -1;
		}
		
		float sine = sin(angle * DEG2RAD);
		yDiff *= (sine * length);
		xDiff *= sqrt(pow(length, 2) - pow(yDiff, 2));

		end = CGPointMake(start.x - xDiff, 
						  start.y - yDiff);
	}
	return end;
}

+ (float) lengthBetweenPoint:(CGPoint)start  andPoint:(CGPoint)end
{
	float x = start.x - end.x;
	float y = start.y - end.y;
	
	return sqrt(x * x + y * y);
}

+ (float) findAngleBetweenPoint:(CGPoint) start andPoint:(CGPoint)end
{
	float a = start.y - end.y;
	float b = start.x - end.x;
	float c = sqrt(a * a + b * b);
	
	float cosine = b / c;
	float angle = acos(cosine) * RAD2DEG;
	
	if(end.y < start.y)
		angle = -angle;
	
	if(angle < 0.f)
	{
		angle = 180.f + (180.f - (-1.f * angle));
	}
	
	if(angle <= 180.f)
		angle = 180.f - angle;
	else
		angle = 360.f - (angle - 180.f);
	
	return angle;	
}

+ (CGPoint) findPointBetweenPoint:(CGPoint)pointA andPoint:(CGPoint)pointB
{
	float angle = [self findAngleBetweenPoint:pointA andPoint:pointB];
	float length = [self lengthBetweenPoint:pointA andPoint:pointB];
	
	return [self findEndPointForStart:pointA withLength:(length / 2) atAngle:angle];
}

//    Return: >0 for point left of the line through point1 and point2
//            =0 for point on the line
//            <0 for point right of the line
+ (char) isPoint:(CGPoint)point toTheLeftOfLineBetween:(CGPoint)point1 and:(CGPoint)point2
{
	return (point2.x - point1.x)*(point.y - point1.y) - (point.x - point1.x)*(point2.y - point1.y);
}
#pragma mark -

#pragma mark Time
+ (double) substractStartTime:(uint64_t)startTime fromEndTime:(uint64_t)endTime
{
	uint64_t difference = endTime - startTime;
    static double conversion = 0.0;
    
    if( conversion == 0.0 )
    {
        mach_timebase_info_data_t info;
        kern_return_t err = mach_timebase_info( &info );
        
		//Convert the timebase into seconds
        if( err == 0  )
			conversion = 1e-9 * (double) info.numer / (double) info.denom;
	}
    
    return conversion * (double) difference;
}
#pragma mark -

#pragma mark Graphics
+ (GLuint) getTextureFromImage:(CGImageRef)image
{
	GLubyte *imageData; 
	CGContextRef context; 
	GLuint texture; 
	size_t width, height; 

	width = CGImageGetWidth(image); 
	height = CGImageGetHeight(image); 

	imageData = (GLubyte*)calloc(width * height * 4, sizeof(GLubyte));
	context = CGBitmapContextCreate(imageData, 
									width, 
									height, 
									8, 
									width * 4, 
									CGImageGetColorSpace(image), 
									kCGImageAlphaPremultipliedLast); 
	
	CGContextDrawImage(context,
					   CGRectMake(0.0,0.0,(CGFloat)width,(CGFloat)height), 
					   image); 
	CGContextRelease(context); 

	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	glTexImage2D(GL_TEXTURE_2D, 
				 0, 
				 GL_RGBA, 
				 width, 
				 height, 
				 0, 
				 GL_RGBA, 
				 GL_UNSIGNED_BYTE, 
				 imageData); 
	free(imageData);

	return texture;
}

+ (CGImageRef) getCGImageAtPath:(NSString*)filePath
{
	CGImageSourceRef  myImageSource;
	NSURL *picturePath;
	
	picturePath = [NSURL fileURLWithPath:filePath];
	
	NSError *err;
	if ([picturePath checkResourceIsReachableAndReturnError:&err] == NO)
	{
		NSLog(@"Invalid path: %@", filePath);
		return NULL;
	}
	
	myImageSource = CGImageSourceCreateWithURL((CFURLRef)picturePath, NULL);
	CGImageRef image = CGImageSourceCreateImageAtIndex(myImageSource,
													   0,
													   NULL);
	CFRelease(myImageSource);
	
	return image;
}
#pragma mark -
@end