//
//  TextRender.mm
//  Finger
//
//  Created by Mood on 9/14/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TextCircle.h"


@implementation TextCircle

- (id) init
{
	if(self = [super init])
	{
		strings = [[NSMutableArray alloc] init];
		stringsForRemoval = [[NSMutableArray alloc] init];
		deadStrings = [[NSMutableDictionary alloc] initWithCapacity:100];

/*		[strings addObject:@"Здравей, приятелю! "];
		[strings addObject:@"Наслади се на питието си! "]; */
		
		[strings addObject:@"Enjoy a good drink! "];
		[strings addObject:@"How is your evening? "];
		[strings addObject:@"Did you have a great day today? "];
		[strings addObject:@"What you gonna do tonight? "];
		
		font = new FTGLPolygonFont("/Users/ivandilchovski/Fonts/Courier.ttf");
		font->FaceSize(30);
		font->UseDisplayList(true);
	}
	
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[lock lock];
	[super processTouches:event];
	
	if([event ignoreEvent])
		return;
	
	NSNumber *uniqueID = event.uid;	
	
//	CGPoint oldPos = event.lastPos;
	CGPoint pos = event.pos;
	
	pos.x *= 640;
	pos.y *= 640;
		
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing TextRender touch down event" ofType:DEBUG_TOUCH];
			LabeledInteractor *text = [[LabeledInteractor alloc] initWithPos:pos];
			text.label = [strings objectAtIndex:(arc4random() % [strings count])];
			text.targetScale = 1.f;
			text.delta = 0.01f;
			text.rotateDelta = TEXT_START_ROTATE_DELTA / FRAMES;
			
			[touches setObject:text forKey:uniqueID];
		} break;
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing TextRender touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			[(LabeledInteractor*)[touches objectForKey:uniqueID] setPosition:pos];
		} break;
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing TextRender touch release event" ofType:DEBUG_TOUCH];
			
			[deadStrings setObject:[touches objectForKey:uniqueID] forKey:uniqueID];
			
			//Use the Delta property to store the lenght of the string to trim when disappearing, as scale is used when calculating the circle's geometry.
			[touches removeObjectForKey:uniqueID];
		} break;
	}
	[lock unlock];
}

- (void) render
{	
	[lock lock];
	
	float circumference, diameter;
	float letterAngle;
	bool rotateLeft;
	LabeledInteractor *text;
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	
	for(uid in keys)
	{
		if(!uid)
			continue;
		
		text = [touches objectForKey:uid];
		const char *string = [text.label UTF8String];
		if(!string)
			continue;
		int length = strlen(string);
		
		letterAngle = 360 / length;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		glColor3f(color.r, color.g, color.b);
		
		glPushMatrix();
		
		circumference = font->Advance(string) * text.scale;
		diameter = circumference / PI;
		float dX = (circumference / length) / 2;
		
		if(!rotateLeft)
		{
			dX = -dX;
			diameter = -diameter;
			letterAngle = -letterAngle;
		}
		
		glTranslated(text.position.x - dX, text.position.y - (diameter / 2), 0);

		glTranslated(dX, (diameter / 2), 0);
		glRotated(text.angle, 0, 0, 1);
		glTranslated(-dX, -(diameter / 2), 0);
				
		for(int i = 0; i < length; i += 1)
		{
			font->Render(&string[i], 1);
			
			glTranslated(font->Advance(&string[i], 1)  * text.scale , 0, 0);
			glRotated(letterAngle, 0, 0, 1);
		}
		
		glPopMatrix();
		
		if((text.scale + text.delta) < text.targetScale)
		{
			text.scale += text.delta;
			if(text.delta < (TEXT_TARGET_DELTA / FRAMES))
				text.delta *= 1 + (TEXT_TARGET_DELTA_STEP / FRAMES);
		}
			
		if(text.rotateLeft)
		{
			text.angle += text.rotateDelta;
			
			if(text.angle >= 360)
				text.angle -= 360;
		}
		else
		{
			text.angle -= text.rotateDelta;
			
			if(text.angle <= 360)
				text.angle += 360;
		}
		
		if(text.rotateDelta > (TEXT_TARGET_ROTATE_DELTA / FRAMES))
			text.rotateDelta -= (TEXT_TARGET_ROTATE_DELTA_STEP / FRAMES);
	}
	
	keys = [deadStrings allKeys];
	for(uid in keys)
	{
		if(!uid)
			continue;
		
		text = [deadStrings objectForKey:uid];
		const char *string = [text.label UTF8String];
		int length = strlen(string);
		rotateLeft = text.rotateLeft;
		
		letterAngle = 360 / length;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		glColor3f(color.r, color.g, color.b);
		
		glPushMatrix();
		
		circumference = font->Advance(string) * text.scale;
		diameter = circumference / PI;
		float dX = (circumference / length) / 2;
		
		if(!rotateLeft)
		{
			dX = -dX;
			diameter = -diameter;
			letterAngle = -letterAngle;
		}
		
		glTranslated(text.position.x - dX, text.position.y - (diameter / 2), 0);
		
		glTranslated(dX, (diameter / 2), 0);
		glRotated(text.angle, 0, 0, 1);
		glTranslated(-dX, -(diameter / 2), 0);
		
		length -= (int) text.charsToTrimAtEnd;
		for(int i = 0; i < length ; i += 1)
		{
			font->Render(&string[i], 1);
			
			glTranslated(font->Advance(&string[i], 1), 0, 0);
			glRotated(letterAngle, 0, 0, 1);
		}
		
		glPopMatrix();
		
		text.charsToTrimAtEnd += 2;
		if(((int)text.scale) > length)
			[stringsForRemoval addObject:uid];
	}
	
	for(uid in stringsForRemoval)
	{
		[deadStrings removeObjectForKey:uid];
	}
	
	if([stringsForRemoval count])
		[stringsForRemoval removeAllObjects];
	[lock unlock];
}

@end
