//
//  TextRender.mm
//  Finger
//
//  Created by Mood on 9/14/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TextRender.h"


@implementation TextRender

- (id) init
{
	if(self = [super init])
	{
		strings = [[NSMutableArray alloc] init];

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
			[touches removeObjectForKey:uniqueID];
		} break;
	}
}

- (void) render
{	
	float circumference, diameter;
	LabeledInteractor *text;
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	
	GLdouble dRadius = 0.1;
	GLdouble dAngle;
	
	glTranslated(0.8 * 640, 320, 0);
	
	glColor3f(1, 1, 1);
	glBegin(GL_LINE_STRIP);
	for(dAngle = 0; dAngle <= 200; dAngle += 0.1)
	{
		glVertex2d(dRadius * cos (dAngle), dRadius * sin(dAngle));
		dRadius *= 1.02;
	}
	glEnd();
	
	for(uid in keys)
	{
		text = [touches objectForKey:uid];
		const char *string = [text.label UTF8String];
		int length = strlen(string);
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		glColor3f(color.r, color.g, color.b);
		
		glPushMatrix();
		glTranslated(text.position.x, text.position.y, 0);
		
		
		circumference = font->Advance(string);
		diameter = circumference / PI;
		float dX = (circumference / length) / 2;

		glTranslated(dX, diameter / 2, 0);
		glRotated(text.angle, 0, 0, 1);
		glTranslated(-dX, -(diameter / 2), 0);
				
		for(int i = 0; i < length; i += 1)
		{
			font->Render(&string[i], 1);
			
			glTranslated(font->Advance(&string[i], 1) , 0, 0);
			glRotated(360.f / length, 0, 0, 1);
		}
		
		glPopMatrix();
		
		text.angle += 1;
	} 
}

@end
