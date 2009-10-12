//
//  Ripples.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "Ripples.h"


@implementation Ripples
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init Ripples" ofType:DEBUG_GENERAL];
		
		newTouches = [[NSMutableDictionary alloc] initWithCapacity:50];
		dieingTouches = [[NSMutableDictionary alloc] initWithCapacity:100];
		deadTouches = [[NSMutableArray alloc] initWithCapacity:100];
	}
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[lock lock];
	[super processTouches:event];
	
	if([event ignoreEvent])
	{
		[lock unlock];
		return;
	}
	
	NSNumber *uniqueID = event.uid;
	CGPoint pos = event.pos;
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing Ripples touch down event" ofType:DEBUG_TOUCH];
			
			
			NSMutableArray *ripple = [[NSMutableArray alloc] initWithCapacity:3];
			for(float i = 1; i <= 3; i++)
			{
				InteractiveObject *circle = [[InteractiveObject alloc] initWithPos:pos];
				circle.targetScale = 1.f / 3.f * i;
				circle.colorSpeed = 1.1f;
				
				circle.scale = 2.f;

				circle.isNew = TRUE;
				circle.delta = (circle.scale - circle.targetScale) / 3;
				
				[ripple addObject:circle];
			}
			
			ClusteredInteractor *cluster = [[ClusteredInteractor alloc] initWithItems:ripple];
			cluster.scale = 0.3;
			cluster.position = pos;
			cluster.visibleItems = 1;
			
			[newTouches setObject:cluster forKey:uniqueID];
			
		} break;
		case TouchMove:
		{
			if((![touches objectForKey:uniqueID]) && (![newTouches objectForKey:uniqueID]))
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing Ripples touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			if([newTouches objectForKey:uniqueID])
			{
				ClusteredInteractor *cluster = [newTouches objectForKey:uniqueID];
				[cluster setItemsPosition:pos];
			} else
			{
				ClusteredInteractor *cluster = [touches objectForKey:uniqueID];
				[cluster setItemsPosition:pos];
			}
			
		} break;
		case TouchRelease:
		{
			if((![touches objectForKey:uniqueID]) && (![newTouches objectForKey:uniqueID]))
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing Ripples touch release event" ofType:DEBUG_TOUCH];
			
			if([touches objectForKey:uniqueID])
			{
				[dieingTouches setObject:[touches objectForKey:uniqueID] forKey:uniqueID];
				[touches removeObjectForKey:uniqueID];
			} else if([newTouches objectForKey:uniqueID])
			{
				[dieingTouches setObject:[newTouches objectForKey:uniqueID] forKey:uniqueID];
				[newTouches removeObjectForKey:uniqueID];
			}
			
			ClusteredInteractor *cluster = [dieingTouches objectForKey:uniqueID];
			NSArray *ripple = cluster.cluster;
			for(InteractiveObject *circle in ripple)
			{
				circle.targetScale = 2.f;
				circle.delta = (circle.targetScale - circle.scale) / 4.f;
			}
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];

	[Logger logMessage:@"Rendering Stars frame" ofType:DEBUG_RENDER];
	
	ClusteredInteractor *cluster;
	NSArray *ripple;
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	InteractiveObject *circle;

	for(uid in keys)
	{
		if([newTouches objectForKey:uid])
		{
			cluster = [newTouches objectForKey:uid];
			for(int i = 0; i < 3; i++)
			{
				InteractiveObject *circle = [cluster.cluster objectAtIndex:i];
				circle.targetScale =  1.f / 3.f * i * 1.05;
				circle.delta = (circle.targetScale - circle.scale) / (15 + arc4random() % 8);
				
				circle.isNew = FALSE;
			}
			
			[newTouches removeObjectForKey:uid];
		}
		
		cluster = [touches objectForKey:uid];
		CGPoint clusterPos = cluster.position;
		float clusterScale = cluster.scale;
		
		ripple = cluster.cluster;
		
		glLoadIdentity();
		
		glTranslated(clusterPos.x, clusterPos.y, 0);
		glScaled(clusterScale, clusterScale, 1);
		glTranslated(-clusterPos.x, -clusterPos.y, 0);
		
		int circles = cluster.visibleItems;
		
		for(int j = 0; j < circles; j++)
		{	
			circle = [ripple objectAtIndex:j];
			CGPoint pos = circle.position;
			RGBA color = circle.color;
			
			if(circle.isScaling)
			{
				if((circle.targetScale - circle.scale) >= circle.delta)
					circle.scale += circle.delta;
				else
				{
					circle.targetScale =  1.f / 3.f * (j + 1) * 0.90;
					circle.delta = (circle.scale - circle.targetScale) / (15 + arc4random() % 8);
					circle.isScaling = FALSE;
				}
			}
			else
			{
				if((circle.scale - circle.targetScale) >= circle.delta)
					circle.scale -= circle.delta;
				else
				{
					circle.targetScale =  1.f / 3.f * (j + 1) * 1.05;
					circle.delta = (circle.targetScale - circle.scale) / (15 + arc4random() % 8);
					circle.isScaling = TRUE;
				}
			}
			
			float scaleFactor = circle.scale;
			
			for(float k = 1; k < 5; k++)
			{
				glLineWidth(k * 2);
				glColor4f(color.r, color.g, color.b, 0.07f);
				glBegin(GL_LINE_LOOP);
				for (int i = 0; i < 360; i++)
				{	
					glVertex2f(cos(DEG2RAD * i) * scaleFactor + pos.x, 
							   sin(DEG2RAD * i) * scaleFactor + pos.y);
				}
				glEnd();
			}
			
			[circle randomizeColor];
		}
	}
	
	keys = [dieingTouches allKeys];
	
	for(uid in keys)
	{
		cluster = [dieingTouches objectForKey:uid];
		CGPoint clusterPos = cluster.position;
		float clusterScale = cluster.scale;
		
		ripple = cluster.cluster;
		
		glLoadIdentity();
		
		glTranslated(clusterPos.x, clusterPos.y, 0);
		glScaled(clusterScale, clusterScale, 1);
		glTranslated(-clusterPos.x, -clusterPos.y, 0);
		
		int circles = cluster.visibleItems;
		
		circle = [ripple objectAtIndex:(circles - 1)];
		
		if((circle.targetScale - circle.scale) >= circle.delta)
		{
			circle.scale += circle.delta;
		}
		else
		{
			if((!circle.isNew) && (cluster.visibleItems > 1))
			{
				cluster.visibleItems--;
				circle.isNew = TRUE;
			} else if (cluster.visibleItems == 1)
				[deadTouches addObject:uid];
		}
		
		for(int j = 0; j < circles; j++)
		{	
			circle = [ripple objectAtIndex:j];
			CGPoint pos = circle.position;
			RGBA color = circle.color;
			
			float scaleFactor = circle.scale;
			
			for(float k = 1; k < 5; k++)
			{
				glLineWidth(k * 2);
				glColor4f(color.r, color.g, color.b, 0.07f);
				glBegin(GL_LINE_LOOP);
				for (int i = 0; i < 360; i++)
				{	
					glVertex2f(cos(DEG2RAD * i) * scaleFactor + pos.x, 
							   sin(DEG2RAD * i) * scaleFactor + pos.y);
				}
				glEnd();
			}
			
			[circle randomizeColor];
		}
		
	}
	
	for(uid in deadTouches)
		[dieingTouches removeObjectForKey:uid];
	if([deadTouches count])
		[deadTouches removeAllObjects];
	
	keys = [newTouches allKeys];
	
	for(uid in keys)
	{
		cluster = [newTouches objectForKey:uid];
		CGPoint clusterPos = cluster.position;
		float clusterScale = cluster.scale;
		
		ripple = cluster.cluster;
		
		glLoadIdentity();
		
		glTranslated(clusterPos.x, clusterPos.y, 0);
		glScaled(clusterScale, clusterScale, 1);
		glTranslated(-clusterPos.x, -clusterPos.y, 0);
		
		int circles = cluster.visibleItems;
		
		for(int j = 0; j <= (circles - 1); j++)
		{
			circle = [ripple objectAtIndex:j];
			CGPoint pos = circle.position;
			RGBA color = circle.color;
			float scaleFactor;
			
			
			if((circle.scale - circle.targetScale) >= circle.delta)
			{
				circle.scale -= circle.delta;
				scaleFactor = circle.scale;
			}
			else
			{
				scaleFactor = circle.targetScale;
				
				if(circle.isNew)
				{
					if(cluster.visibleItems < [ripple count])
						cluster.visibleItems++;
					
					circle.isNew = FALSE;
				} 
				else if((cluster.visibleItems == [ripple count]) && (!circle.isNew) && (j == 2))
				{
					[touches setObject:cluster forKey:uid];
				}
			}
			
			for(float k = 1; k < 5; k++)
			{
				glLineWidth(k * 2);
				glColor4f(color.r, color.g, color.b, 0.07f);
				glBegin(GL_LINE_LOOP);
				for (int i = 0; i < 360; i++)
				{	
					glVertex2f(cos(DEG2RAD * i) * scaleFactor + pos.x, 
							   sin(DEG2RAD * i) * scaleFactor + pos.y);
				}
				glEnd();
			}
			
			[circle randomizeColor];
		}
	}
	
	[lock unlock];
}
@end
