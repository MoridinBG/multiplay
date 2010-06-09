//
//  Steps.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/29/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Steps.h"

@implementation Steps

- (id) init
{
	if(self = [super init])
	{
		frame = 0;
	}
	return self;
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat
{
	CGLContextObj contextObj = [super copyCGLContextForPixelFormat:pixelFormat];
	
	NSString *path = @"/Users/ivandilchovski/Pictures/Multitouch/Foot Right White.png";
	leftFootTexture = [GlobalFunctions getTextureFromImage:[GlobalFunctions getCGImageAtPath:path]];
	
	path = @"/Users/ivandilchovski/Pictures/Multitouch/Foot Left White.png";
	rightFootTexture = [GlobalFunctions getTextureFromImage:[GlobalFunctions getCGImageAtPath:path]];
	
	return contextObj;
}

- (void) drawGL
{
	NSArray *keys = [objects allKeys];
	for(NSNumber *key in keys)
	{
		InteractiveObject *object = [objects objectForKey:key];
		
		float moveLength = 0.f;
		int count = [object.positionHistory count] - 2;
		for(int i = count; ((i > 0) && (i > (count - 4))); i--)
		{
			CGPoint pointA = [[object.positionHistory objectAtIndex:i + 1] getCGPoint];
			CGPoint pointB = [[object.positionHistory objectAtIndex:i ] getCGPoint];
			moveLength += [GlobalFunctions lengthBetweenPoint:pointA andPoint:pointB];
		}
		
		if(moveLength < 0.04f)
			object.framesStatic++;
		else
			object.framesStatic = 0;
		
		object.frames++;
		if(object.frames >= 12)
		{
			object.frames = 0;
			if(object.framesStatic < 5)
				object.generalFlag = !object.generalFlag;
		}
		
		float positions = [object.positionHistory count];
		float index = 1;
		float step = 0;
		CGPoint lastStepPosition;
		BOOL right = object.generalFlag;
		
		if([object.positionHistory count] >= 19)
		   lastStepPosition = [[object.positionHistory objectAtIndex:(positions - 19)] getCGPoint];
		
		for(int i = positions - 20; i > 0; i--)
		{
			if(step > MAX_STEPS)
				break;
			
			CGPoint point = [[object.positionHistory objectAtIndex:i] getCGPoint];
			if([GlobalFunctions lengthBetweenPoint:lastStepPosition andPoint:point] < 0.1f)
			{
				index++;
				continue;
			}
			
			CGPoint middlePoint = [GlobalFunctions findPointBetweenPoint:lastStepPosition andPoint:point];
			float textureWidth = STEP_WIDTH / 2.f;
			float textureHeight = STEP_WIDTH / 4.f;
			float angle = [GlobalFunctions findAngleBetweenPoint:point andPoint:lastStepPosition];

			glEnable(GL_TEXTURE_2D);
			
			if(right)
			{
				glBindTexture(GL_TEXTURE_2D, rightFootTexture);
				middlePoint = [GlobalFunctions findEndPointForStart:middlePoint
														 withLength:STEP_WIDTH / 10.f
															atAngle:angle + 90.f];
			} else
			{
				glBindTexture(GL_TEXTURE_2D, leftFootTexture);
				middlePoint = [GlobalFunctions findEndPointForStart:middlePoint
														 withLength:STEP_WIDTH / 10.f
															atAngle:angle - 90.f];
			}

			glColor4f(object.color.r, object.color.g, object.color.b,1.f - (index / positions));
			glPushMatrix();
			glTranslated(middlePoint.x, middlePoint.y, 0.f);
			glRotated(angle, 0.f, 0.f, 1.f);
			
			glBegin(GL_QUADS);
			glTexCoord2f(0.0f, 0.0f);
			glVertex2f(-textureWidth, -textureHeight);
			
			glTexCoord2f(1.0f, 0.0f);
			glVertex2f(textureWidth, -textureHeight);
			
			glTexCoord2f(1.0f, 1.0f);
			glVertex2f(textureWidth, textureHeight);
			
			glTexCoord2f(0.0f, 1.0f);
			glVertex2f(-textureWidth, textureHeight);
			glEnd();
			
			glPopMatrix();
			
			lastStepPosition = point;
			index++;
			step++;
			right = !right;
		}
		
		glDisable(GL_TEXTURE_2D);
	}
/*	
	for(NSNumber *key in keys)
	{
		InteractiveObject *object = [objects objectForKey:key];
		[object renderBasicShape];
	}
//*/
}
@end
