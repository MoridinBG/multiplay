//
//  LightningConnection.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 6/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "LightningConnection.h"


@implementation LightningConnection

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
		for(int i = 0; i < ARCS; i++)
			arcs[i] = [[AlphaChangeContainer alloc] initRandom];
		
	}
	return self;
}

- (void) generateArcAt:(int) index
{	
	if(glIsList(displayLists[index]))
	   glDeleteLists(displayLists[index], 1);
	
	displayLists[index] = glGenLists(1);
	glNewList(displayLists[index],GL_COMPILE);
	
	
	
	glEndList();
}

-(void) render
{	
	glLineWidth(3);
	float length = self.length;
	
	CGPoint endPoint = (_endA.position.x >= _endB.position.x) ? _endA.position : _endB.position;
	CGPoint prevPoint = (_endA.position.x >= _endB.position.x) ? _endB.position : _endA.position;
	
	
	glBegin(GL_LINES);
	glColor3f(0.f, 0.75f, 1.f);
//	for (int i = 0; i < 5; i++)
	do	
	{
		float distance = length / 30.f * (1 + arc4random() % 3);
		int sign = ((arc4random() % 10) > 5) ? -1 : 1;
		int angle = (arc4random() % 40) * sign;
		CGPoint nextPoint = [GlobalFunctions findEndPointForStart:prevPoint
													   withLength:distance
														  atAngle:angle];
		glVertex2f(prevPoint.x, prevPoint.y);
		glVertex2f(nextPoint.x, nextPoint.y);
		
		prevPoint = nextPoint;
		distance = length / 30.f * (1 + arc4random() % 3);
		angle = [GlobalFunctions findAngleBetweenPoint:prevPoint
											  andPoint:endPoint];
		nextPoint = [GlobalFunctions findEndPointForStart:prevPoint
											   withLength:distance
												  atAngle:angle];
		
		glVertex2f(prevPoint.x, prevPoint.y);
		glVertex2f(nextPoint.x, nextPoint.y);
		
		prevPoint = nextPoint;
		
		
	} while([GlobalFunctions lengthBetweenPoint:prevPoint andPoint:_endB.position] > 0.05f);
	glEnd();
}

@end
