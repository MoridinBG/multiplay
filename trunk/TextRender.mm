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
		GLint ctx, myFont;
		strings = [[NSMutableArray alloc] init];
		
		[strings addObject:@"Enjoy a good drink! "];
		[strings addObject:@"How is your evening? "];
		[strings addObject:@"Did you have a great day today? "];
		[strings addObject:@"Random test string from me. "];
		[strings addObject:@"What you gonna do? "];
		
		ctx = glcGenContext();
		glcContext(ctx);
		glcAppendCatalog("/Users/ivandilchovski/Fonts/");
		
		glcRenderStyle(GLC_TRIANGLE);
		glcStringType(GLC_UTF8_QSO);
		glcEnable(GLC_GL_OBJECTS);
		
		myFont = glcGenFontID();
		glcNewFontFromFamily(myFont, "Courier New");
		glcFont(myFont);
	}
	
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[super processTouches:event];
	
	if([event ignoreEvent])
		return;
	
	NSNumber *uniqueID = event.uid;
	
	CGPoint oldPos = event.lastPos;
	CGPoint pos = event.pos;
		
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing TextRender touch down event" ofType:DEBUG_TOUCH];
			InteractiveObject *text = [[InteractiveObject alloc] initWithPos:pos];
			[text setLabel:[strings objectAtIndex:(arc4random() % [strings count])]];
			
			[touches setObject:text forKey:uniqueID];
		} break;
		case TouchMove:
		{
			[Logger logMessage:@"Processing TextRender touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];
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
	InteractiveObject *text;
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	
	for(uid in keys)
	{
		text = [touches objectForKey:uid];
		NSString *string = text.label;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		glColor3f(color.r, color.g, color.b);
				glPushMatrix();
		
		glTranslated(text.position.x, text.position.y, 0);
		glScaled(FONT_SCALE, FONT_SCALE, 0);
		
		
		glcMeasureString(GL_TRUE, [string UTF8String]);
		glcGetStringMetric(GLC_BASELINE, baseline);
		
		circumference = baseline[2] - baseline[0];
		circumference += [string length] * 0.1;
		
		diameter = circumference / PI;
		
		float dX = (circumference / [string length]) / 2;
		glTranslated(dX, diameter / 2, 0);
		glRotated(text.angle, 0, 0, 1);
		glTranslated(-dX, -(diameter / 2), 0);
		
		
		for(int i = 0; i < [string length]; i += 1)
		{
			glcRenderChar([string characterAtIndex:i]);
			
			glTranslated(0.1 , 0, 0);
			glRotated(360.f / [string length], 0, 0, 1);
		}
		
		glPopMatrix();
		
		text.angle += 1;
	}
}

@end
