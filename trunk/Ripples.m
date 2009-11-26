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
		
		newTouches = [[NSMutableDictionary alloc] initWithCapacity:100];
		dieingTouches = [[NSMutableDictionary alloc] initWithCapacity:100];
		deadTouches = [[NSMutableArray alloc] initWithCapacity:100];
		donuts = [[NSMutableDictionary alloc] initWithCapacity:100];
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
				circle.colorSpeed = RIPPLE_COLOR_CHANGE_SPEED / FRAMES;
				
				circle.scale = 2.f;

				circle.isNew = TRUE;
				circle.delta = (circle.scale - circle.targetScale) / (FRAMES / RIPPLE_APPEAR_TIME_FACTOR);
				
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
				circle.delta = (circle.targetScale - circle.scale) / 8.f;
			}
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	
	[Logger logMessage:@"Rendering Stars frame" ofType:DEBUG_RENDER];
	
	ClusteredInteractor *ringsCluster;
	NSArray *rings;
	NSNumber *uid;
	InteractiveObject *circle;
	NSArray *keys = [touches allKeys];
	ClusteredInteractor *donutsCluster;
	
	float *cosArray = [SingletonVars instance].cosArray;
	float *sinArray = [SingletonVars instance].sinArray;
	
	for(uid in keys)
	{
		if([newTouches objectForKey:uid])
		{
			ringsCluster = [newTouches objectForKey:uid];
			for(int i = 1; i <= 3; i++)
			{
				InteractiveObject *circle = [ringsCluster.cluster objectAtIndex:i - 1];
				circle.targetScale =  1.f / 3.f * i * (1.07 - (i / 100.f));
				circle.delta = (circle.targetScale - circle.scale) / ((FRAMES * 0.66f) + (arc4random() % (FRAMES  / 3)));
				
				circle.isNew = FALSE;
			}
			
			NSMutableArray *donutsArray = [[NSMutableArray alloc] initWithCapacity:3];
			for(float i = 1; i <= 3; i++)
			{
				InteractiveObject *donut = [[InteractiveObject alloc] initWithPos:[(InteractiveObject*)[ringsCluster.cluster objectAtIndex:0] position]];
				donut.isNew = TRUE;
				donut.alphaDelta = DONUT_ALPHA_DELTA_FACTOR / FRAMES;
				
				[donutsArray addObject:donut];
			}
			
			[(InteractiveObject*)[donutsArray objectAtIndex:0] setScale:0.f];
			donutsCluster = [[ClusteredInteractor alloc] initWithItems:donutsArray];
			donutsCluster.visibleItems = 2;
			
			RGBA color;
			color.r = (((float)(arc4random() % 255)) / 255);
			color.g = (((float)(arc4random() % 255)) / 255);
			color.b = (((float)(arc4random() % 255)) / 255);
			[donutsCluster setClusterColor:color];
			
			[donuts setObject:donutsCluster forKey:uid];
			
			[newTouches removeObjectForKey:uid];
		}
		else
		{
			donutsCluster = [donuts objectForKey:uid];
		}

		
		if((![activeUIDs containsObject:uid]) && (![[newTouches allKeys] containsObject:uid]))
		{
			[deadTouches addObject:uid];
		}
		
		
		ringsCluster = [touches objectForKey:uid];
		CGPoint clusterPos = ringsCluster.position;
		float clusterScale = ringsCluster.scale;
		
		rings = ringsCluster.cluster;
		
		glLoadIdentity();
		glTranslated(clusterPos.x, clusterPos.y, 0);
		glScaled(clusterScale, clusterScale, 1);
		glTranslated(-clusterPos.x, -clusterPos.y, 0);
		
		int circles = ringsCluster.visibleItems;
		for(int j = 0; j < circles; j++)
		{	
			circle = [rings objectAtIndex:j];
			CGPoint pos = circle.position;
			RGBA color = circle.color;
			
			if(circle.isScaling)
			{
				if((circle.targetScale - circle.scale) >= circle.delta)
					circle.scale += circle.delta;
				else
				{
					circle.targetScale =  1.f / 3.f * (j + 1) * (0.89 + ((j + 1) / 100.f));
					circle.delta = (circle.scale - circle.targetScale) / ((FRAMES * 0.66f) + (arc4random() % (FRAMES  / 3)));;
					circle.isScaling = FALSE;
				}
			}
			else
			{
				if((circle.scale - circle.targetScale) >= circle.delta)
					circle.scale -= circle.delta;
				else
				{
					circle.targetScale =  1.f / 3.f * (j + 1) * (1.09 - ((j + 1) / 100.f));
					circle.delta = (circle.targetScale - circle.scale) / ((FRAMES * 0.66f) + (arc4random() % (FRAMES  / 3)));;
					circle.isScaling = TRUE;
				}
			}
			
			float scaleFactor = circle.scale;
			for(float k = 1; k < 8; k++)
			{
				glLineWidth(k * RIPPLE_WIDTH_FACTOR);
				glColor4f(color.r, color.g, color.b, RIPPLE_ALPHA_FACTOR);
				glBegin(GL_LINE_LOOP);
				for (int i = 0; i < 360; i++)
				{	
					glVertex2f(cos(DEG2RAD * i) * scaleFactor * RIPPLE_RADIUS_FACTOR + pos.x, 
							   sin(DEG2RAD * i) * scaleFactor * RIPPLE_RADIUS_FACTOR + pos.y);
				}
				glEnd();
			}
			
			[circle randomizeColor];
		}
		
		InteractiveObject *donut = [donutsCluster.cluster objectAtIndex:donutsCluster.visibleItems];
		donut.targetScale = [(InteractiveObject*)[rings objectAtIndex:donutsCluster.visibleItems] scale];
		donut.newColor = [(InteractiveObject*)[rings objectAtIndex:donutsCluster.visibleItems] color];

		if(donutsCluster.visibleItems == 0)
		{
			donut.scale = 0.f;
			RGBA color = {1.f, 1.f, 1.f, 1.f};
			donut.color = color;
		}
		else
		{
			donut.scale = [(InteractiveObject*)[rings objectAtIndex:(donutsCluster.visibleItems - 1)] scale];
			donut.color = [(InteractiveObject*)[rings objectAtIndex:(donutsCluster.visibleItems - 1)] color];
		}
		
		CGPoint pos = circle.position;
		
		float innerRadius = donut.scale * RIPPLE_RADIUS_FACTOR * 1.12f;
		float outerRadius = donut.targetScale * RIPPLE_RADIUS_FACTOR * 0.93f;
		
		RGBA innerColor = donut.color;
		RGBA outerColor = donut.newColor;
			
		glBegin(GL_TRIANGLE_STRIP);
		for(int i = 0; i <= SECTORS_STARS; i++) 
		{
			glColor4f(outerColor.r, outerColor.g, outerColor.b, donutsCluster.clusterAlpha);
			glVertex2f(innerRadius * cosArray[i] + pos.x, 
					   innerRadius * sinArray[i] + pos.y);
			
			glColor4f(innerColor.r, innerColor.g, innerColor.b, donutsCluster.clusterAlpha);			
			glVertex2f(outerRadius * cosArray[i] + pos.x, 
					   outerRadius * sinArray[i] + pos.y);
		}
		glEnd();
		
		if(donutsCluster.clusterAlpha >= donut.alphaDelta)
		{
			donutsCluster.clusterAlpha -= donut.alphaDelta;
		}
		else 
		{
			donutsCluster.clusterAlpha = 1.f;
			
			if(donutsCluster.visibleItems > 0)
			{
				donutsCluster.visibleItems--;
			}
			else
			{
				[donut setRandomColor];
				[donutsCluster setClusterColor:donut.color];
				
				donutsCluster.visibleItems = 2;
			}
		}

	}
	
	keys = [dieingTouches allKeys];
	
	for(uid in keys)
	{
		ringsCluster = [dieingTouches objectForKey:uid];
		CGPoint clusterPos = ringsCluster.position;
		float clusterScale = ringsCluster.scale;
		
		rings = ringsCluster.cluster;
		
		glLoadIdentity();
		
		glTranslated(clusterPos.x, clusterPos.y, 0);
		glScaled(clusterScale, clusterScale, 1);
		glTranslated(-clusterPos.x, -clusterPos.y, 0);
		
		int circles = ringsCluster.visibleItems - 1;
		
		circle = [rings objectAtIndex:circles];
		
		if(((circle.targetScale - circle.scale) >= circle.delta) && (circle.delta != 0))
		{
			circle.scale += circle.delta;
		}
		else
		{
			if(ringsCluster.visibleItems >= 2)
			{
				ringsCluster.visibleItems--;
			} else if (ringsCluster.visibleItems <= 1)
			{
				[deadTouches addObject:uid];
			}
		}
		
		for(int j = 0; j < circles; j++)
		{	
			circle = [rings objectAtIndex:j];
			CGPoint pos = circle.position;
			RGBA color = circle.color;
			
			float scaleFactor = circle.scale;
			
			for(float k = 1; k < 8; k++)
			{
				glLineWidth(k * RIPPLE_WIDTH_FACTOR);
				glColor4f(color.r, color.g, color.b, RIPPLE_ALPHA_FACTOR);
				glBegin(GL_LINE_LOOP);
				for (int i = 0; i < 360; i++)
				{	
					glVertex2f(cos(DEG2RAD * i) * scaleFactor * RIPPLE_RADIUS_FACTOR + pos.x, 
							   sin(DEG2RAD * i) * scaleFactor * RIPPLE_RADIUS_FACTOR + pos.y);
				}
				glEnd();
			}
			
			[circle randomizeColor];
		}
		
	}
	
	for(uid in deadTouches)
	{
		if([[dieingTouches allKeys] containsObject:uid])
			[dieingTouches removeObjectForKey:uid];
		else if([[touches allKeys] containsObject:uid])
			[touches removeObjectForKey:uid];
	}
		
	if([deadTouches count])
		[deadTouches removeAllObjects];
	
	keys = [newTouches allKeys];
	
	for(uid in keys)
	{
		ringsCluster = [newTouches objectForKey:uid];
		CGPoint clusterPos = ringsCluster.position;
		float clusterScale = ringsCluster.scale;
		
		rings = ringsCluster.cluster;
		
		glLoadIdentity();
		
		glTranslated(clusterPos.x, clusterPos.y, 0);
		glScaled(clusterScale, clusterScale, 1);
		glTranslated(-clusterPos.x, -clusterPos.y, 0);
		
		int circles = ringsCluster.visibleItems;
		
		for(int j = 0; j <= (circles - 1); j++)
		{
			circle = [rings objectAtIndex:j];
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
					if(ringsCluster.visibleItems < [rings count])
						ringsCluster.visibleItems++;
					
					circle.isNew = FALSE;
				} 
				else if((ringsCluster.visibleItems == [rings count]) && (!circle.isNew) && (j == 2))
				{
					circle.scale = 1.0f;
					[touches setObject:ringsCluster forKey:uid];
				}
			}
			
			for(float k = 1; k < 8; k++)
			{
				glLineWidth(k * RIPPLE_WIDTH_FACTOR);
				glColor4f(color.r, color.g, color.b, RIPPLE_ALPHA_FACTOR);
				glBegin(GL_LINE_LOOP);
				for (int i = 0; i < 360; i++)
				{	
					glVertex2f(cos(DEG2RAD * i) * scaleFactor * RIPPLE_RADIUS_FACTOR + pos.x, 
							   sin(DEG2RAD * i) * scaleFactor * RIPPLE_RADIUS_FACTOR + pos.y);
				}
				glEnd();
			}
			
			[circle randomizeColor];
		}
	}
	
	[lock unlock];
}
@end
