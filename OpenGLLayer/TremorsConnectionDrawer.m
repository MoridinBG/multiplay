//
//  TremorsConnectionDrawer.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/23/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "TremorsConnectionDrawer.h"


@implementation TremorsConnectionDrawer

- (id) initWithendA:(InteractiveObject*) endA
			   endB:(InteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending
{
	if(self = [super initWithendA:endA
							 endB:endB
					  beginningAt:beginnning
						 endingAt:ending])
	{
		for(int i = 0; i < LINES; i++)
		{
			lines[i] = [[AlphaChangeContainer alloc] initRandom];

		}
	}
	
	return self;
}

-(void) render
//TODO: Draw with begin && end factors. Shorten when one end disappears
{
	glLineWidth(3);
	RGBA *firstColor = _endA.color;
	RGBA *secondColor = _endB.color;
	
	float angle = [GlobalFunctions findAngleBetweenPoint:_endA.position andPoint:_endB.position];
	
	CGPoint pointsA[LINES];
	CGPoint pointsB[LINES];
	int middleIndex = (LINES / 2);
	
	for(int i = 0; i < LINES; i++)
	{
		lines[i].framesTillChange--;
		if(!lines[i].framesTillChange)
		{
			lines[i].changeSign *= -1;
			lines[i].alpha = (lines[i].changeSign > 0) ? 0.f : 1.f;
			lines[i].framesTillChange = 10 + (arc4random() % 50);
			lines[i].changeStep = 1.f / lines[i].framesTillChange;
		}
		
		lines[i].alpha += lines[i].changeSign * lines[i].changeStep;
		
		int signChanger = (i < (LINES / 2)) ? 1 : -1;
		float length = (i < (LINES / 2)) ? (LINES_DISTANCE + i * LINES_DISTANCE) : ((i - middleIndex) * LINES_DISTANCE);
		
		pointsA[i] = [GlobalFunctions findEndPointForStart:_endA.position 
													  withLength:length
														 atAngle:angle + (signChanger * 90.f)];
		
		pointsB[i] = [GlobalFunctions findEndPointForStart:pointsA[i]
													  withLength:self.length
														 atAngle:angle];
	}
	
	pointsA[middleIndex] = _endB.position;
	pointsB[middleIndex] = [GlobalFunctions findEndPointForStart:pointsA[middleIndex]
															withLength:self.length
															   atAngle:180.f + angle];
	for(int i = 0; i < LINES; i++)
	{

		glBegin(GL_LINES);
		glColor4f(firstColor.r, firstColor.g, firstColor.b, lines[i].alpha);
		glVertex2f(pointsA[i].x,
				   pointsA[i].y);
		glColor4f(secondColor.r, secondColor.g, secondColor.b, lines[i].alpha);
		glVertex2f(pointsB[i].x,
				   pointsB[i].y);
		glEnd();
	}
}

@end
