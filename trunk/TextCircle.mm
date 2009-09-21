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
			text.delta = 0.01;
			text.rotateDelta = 3;
			
			[touches setObject:text forKey:uniqueID];
		} break;
		case TouchMove:
		{
			[Logger logMessage:@"Processing TextRender touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			[(LabeledInteractor*)[touches objectForKey:uniqueID] setPosition:pos];
		} break;
		case TouchRelease:
		{
			[Logger logMessage:@"Processing TextRender touch release event" ofType:DEBUG_TOUCH];
			
			[deadStrings setObject:[touches objectForKey:uniqueID] forKey:uniqueID];
			
			//Use the Delta property to store the lenght of the string to trim when disappearing, as scale is used when calculating the circle's geometry.
			[[deadStrings objectForKey:uniqueID] setDelta:0.f];
			[touches removeObjectForKey:uniqueID];
		} break;
	}
}

- (void) render
{	
	float circumference, diameter;
	float scale, delta, angle, rotateDelta;
	bool rotateLeft;
	LabeledInteractor *text;
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	
	for(uid in keys)
	{
		text = [touches objectForKey:uid];
		const char *string = [text.label UTF8String];
		int length = strlen(string);
		scale = text.scale;
		delta = text.delta;
		rotateDelta = text.rotateDelta;
		rotateLeft = text.rotateLeft;
		
		angle = 360 / length;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		glColor3f(color.r, color.g, color.b);
		
		glPushMatrix();
		
		circumference = font->Advance(string) * scale;
		diameter = circumference / PI;
		float dX = (circumference / length) / 2;
		
		if(!rotateLeft)
		{
			dX = -dX;
			diameter = -diameter;
			angle = - angle;
		}
		
		glTranslated(text.position.x - dX, text.position.y - (diameter / 2), 0);

		glTranslated(dX, (diameter / 2), 0);
		glRotated(text.angle, 0, 0, 1);
		glTranslated(-dX, -(diameter / 2), 0);
				
		for(int i = 0; i < length; i += 1)
		{
			font->Render(&string[i], 1);
			
			glTranslated(font->Advance(&string[i], 1)  * text.scale , 0, 0);
			glRotated(angle, 0, 0, 1);
		}
		
		glPopMatrix();
		
		if (scale  < 1.f)
		{
			text.scale += delta;
			if(delta < 0.06)
				text.delta *= 1.15;
		}
			
		if(rotateLeft)
		{
			text.angle += rotateDelta;
			
			if(text.angle >= 360)
				text.angle -= 360;
		}
		else
		{
			text.angle -= rotateDelta;
			
			if(text.angle <= 360)
				text.angle += 360;
		}
		
		if(rotateDelta > 1)
			text.rotateDelta -= 0.1;
	}
	
	keys = [deadStrings allKeys];
	for(uid in keys)
	{
		text = [deadStrings objectForKey:uid];
		const char *string = [text.label UTF8String];
		int length = strlen(string);
		scale = text.scale;
		delta = text.delta;
		rotateLeft = text.rotateLeft;
		
		angle = 360 / length;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		glColor3f(color.r, color.g, color.b);
		
		glPushMatrix();
		
		circumference = font->Advance(string) * scale;
		diameter = circumference / PI;
		float dX = (circumference / length) / 2;
		
		if(!rotateLeft)
		{
			dX = -dX;
			diameter = -diameter;
			angle = -angle;
		}
		
		glTranslated(text.position.x - dX, text.position.y - (diameter / 2), 0);
		
		glTranslated(dX, (diameter / 2), 0);
		glRotated(text.angle, 0, 0, 1);
		glTranslated(-dX, -(diameter / 2), 0);
		
		length -= (int) delta;
		for(int i = 0; i < length ; i += 1)
		{
			font->Render(&string[i], 1);
			
			glTranslated(font->Advance(&string[i], 1), 0, 0);
			glRotated(angle, 0, 0, 1);
		}
		
		glPopMatrix();
		
		text.delta += 1.2f;
		if(((int)text.scale) > length)
			[stringsForRemoval addObject:uid];
	}
	
	for(uid in stringsForRemoval)
	{
		[deadStrings removeObjectForKey:uid];
	}
	
	if([stringsForRemoval count])
		[stringsForRemoval removeAllObjects];
}

@end
