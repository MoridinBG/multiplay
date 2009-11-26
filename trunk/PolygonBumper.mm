//
//  PolygonBumper.mm
//  Finger
//
//  Created by Ivan Dilchovski on 11/20/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "PolygonBumper.h"


@implementation PolygonBumper
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init PolygonBumper" ofType:DEBUG_GENERAL];
		
		polygons = [[NSMutableArray alloc] initWithCapacity:MAX_ACTIVE_POLYGONS];
		dieingPolygons = [[NSMutableArray alloc] initWithCapacity:MAX_ACTIVE_POLYGONS];
		deadPolygons = [[NSMutableArray alloc] initWithCapacity:MAX_ACTIVE_POLYGONS];
		
		polygonCreator = [NSTimer scheduledTimerWithTimeInterval:5.0
														  target:self
														selector:@selector(createPolygon:)
														userInfo:nil
														 repeats:YES];
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
	CGPoint lastPos = event.lastPos;
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing PolygonBumper touch down event" ofType:DEBUG_TOUCH];
			
			RGBA color;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
			
			InteractiveObject *spot = [[InteractiveObject alloc] initWithPos:pos];
			spot.targetScale = 1.f;
			spot.delta = (spot.targetScale - spot.scale) / (FRAMES / 2);
			spot.color = color;
			spot.physicsData = [physics createCirclularBodyWithRadius:TOUCH_PHYSICS_BODY_SIZE atPosition:pos];
			[physics attachMouseJointToBody:(b2Body*)spot.physicsData withId:uniqueID];
			
			[touches setObject:spot forKey:uniqueID];
			
		} break;
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			[Logger logMessage:@"Processing PolygonBumper touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			b2Body* body = (b2Body*)[[touches objectForKey:uniqueID] physicsData];
			if(!body)
			{
				[lock unlock];
				return;
			}
			
			InteractiveObject *spot = [touches objectForKey:uniqueID];
			spot.position = pos;
			[physics updateMouseJointWithId:uniqueID toPosition:pos];
			
			[spot.positionHistoryQueue addObject:[[PointObj alloc] initWithPoint:lastPos]];
			if([spot.positionHistoryQueue count] > MAX_PREVIOUS_POSITION_QUEUE_DEPTH)
				[spot.positionHistoryQueue removeObjectAtIndex:0];
			
		} break;
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			[Logger logMessage:@"Processing PolygonBumper touch release event" ofType:DEBUG_TOUCH];
			
			[physics detachMouseJointWithId:uniqueID];
			[physics destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
			[touches removeObjectForKey:uniqueID];
			
		} break;
	}
	
	[lock unlock];
}

- (void) createPolygon:(NSTimer*) theTimer
{
	[lock lock];
	
	if(([polygons count] + [dieingPolygons count]) >= MAX_POLYGONS)
	{
		[lock unlock];
		return;
	}
	
	float x = ((arc4random() % 15) + 1) / 10.f;
	float y = ((arc4random() % 9) + 1) / 10.f;
	CGPoint position = {x, y};
	RGBA color;
	
	GeometricObject *polygon;
	
	float smallRadius;
	do
	{
		smallRadius = MIN_POLYGON_RADIUS / 100.f + ((arc4random() % MAX_POLYGON_RADIUS - MIN_POLYGON_RADIUS) / 100.f);
	} while(smallRadius > MAX_POLYGON_RADIUS);
	
	float largeRadius = 1.5 * smallRadius + (arc4random() % MAX_POLYGON_RADIUS) / 100.f;
	
	int polygonType = arc4random() % 3;
	
	switch(polygonType) 
	{
		case 0:
		{
			int numVertices =  5 + arc4random() % (MAX_POLYGON_VERTICES - 3);
			CGPoint *vertices = (CGPoint*) malloc(numVertices * sizeof(CGPoint));
			RGBA *vertexColors = (RGBA*) malloc(numVertices * sizeof(RGBA));

			color.r = (((float)(arc4random() % 255)) / 255);
			color.g = (((float)(arc4random() % 255)) / 255);
			color.b = (((float)(arc4random() % 255)) / 255);
			vertexColors[0] = color;
			
			for (int i = 1; i < numVertices; i++)
			{
				float degInRad = (i - 2) * (360.f / (numVertices - 2)) * DEG2RAD;
				CGPoint vertex = {cos(degInRad) * smallRadius, 
								  sin(degInRad) * smallRadius};
				vertices[i] = vertex;
				
				color.r = (((float)(arc4random() % 255)) / 255);
				color.g = (((float)(arc4random() % 255)) / 255);
				color.b = (((float)(arc4random() % 255)) / 255);
				
				vertexColors[i] = color;
			}
			
			polygon = [[GeometricObject alloc] initWithPosition:position
																			type:GL_POLYGON
																		vertices:vertices
																 andNumVertices:numVertices];
			
			polygon.colors = vertexColors;
			
			CGSize size = {2 * smallRadius, 2 * smallRadius};
			polygon.size = size;
			polygon.scale = 0.f;
			polygon.physicsData = [physics createRectangularBodyWithSize:size
															  atPosition:position
															   rotatedAt:0];
			[polygons addObject:polygon];
		} break;
		case 1:
		{
			int numVertices =  3 + arc4random() % (MAX_POLYGON_VERTICES);
			CGPoint *vertices = (CGPoint*) malloc((2 * numVertices) * sizeof(CGPoint));
			RGBA *vertexColors = (RGBA*) malloc((2 * numVertices) * sizeof(RGBA));
			
			color.r = (((float)(arc4random() % 255)) / 255);
			color.g = (((float)(arc4random() % 255)) / 255);
			color.b = (((float)(arc4random() % 255)) / 255);
			vertexColors[0] = color;
			
			for(int i = 1; i < (2 * numVertices); i++)
			{
				float radius;
				if(i % 2)
					radius = largeRadius;
				else
					radius = smallRadius;
				
				float degInRad =  (i - 1) * (360.f / (numVertices - 1)) * 0.5 * DEG2RAD;
				CGPoint vertex = {cos(degInRad) * radius,
								  sin(degInRad) * radius};
				vertices[i] = vertex;
				
				color.r = (((float)(arc4random() % 255)) / 255);
				color.g = (((float)(arc4random() % 255)) / 255);
				color.b = (((float)(arc4random() % 255)) / 255);
				
				vertexColors[i] = color;
			}
			polygon = [[GeometricObject alloc] initWithPosition:position
																			type:GL_POLYGON
																		vertices:vertices
																  andNumVertices:2 * numVertices];
			polygon.colors = vertexColors;
			
			CGSize size = {2 * largeRadius, 2 * largeRadius};
			polygon.size = size;
			polygon.scale = 0.f;
			polygon.physicsData = [physics createRectangularBodyWithSize:size
															  atPosition:position
															   rotatedAt:0];
			[polygons addObject:polygon];
		} break;
		case 2:
		{
			int numVertices =  25;
			CGPoint *vertices = (CGPoint*) malloc(numVertices * sizeof(CGPoint));
			RGBA *vertexColors = (RGBA*) malloc(numVertices * sizeof(RGBA));

			color.r = (((float)(arc4random() % 255)) / 255);
			color.g = (((float)(arc4random() % 255)) / 255);
			color.b = (((float)(arc4random() % 255)) / 255);
			vertexColors[0] = color;
			
			for (int i = 1; i < numVertices; i++)
			{
				float degInRad = (i - 2) * (360.f / (numVertices - 2)) * DEG2RAD;
				CGPoint vertex = {cos(degInRad) * smallRadius, 
								  sin(degInRad) * smallRadius};
				vertices[i] = vertex;
				
				if(!(i % 4))
				{
					color.r = (((float)(arc4random() % 255)) / 255);
					color.g = (((float)(arc4random() % 255)) / 255);
					color.b = (((float)(arc4random() % 255)) / 255);
				}
				
				vertexColors[i] = color;
			}
			
			polygon = [[GeometricObject alloc] initWithPosition:position
																			type:GL_POLYGON
																		vertices:vertices
																  andNumVertices:numVertices];
			
			polygon.colors = vertexColors;
			polygon.physicsData = [physics createCirclularBodyWithRadius:smallRadius
															  atPosition:position];
			CGSize size = {0.f,0.f};
			polygon.size = size;
			polygon.scale = 0.f;
			
			[polygons addObject:polygon];
		} break;
	}
	
	polygon.scale = 0.f;
	polygon.delta = (polygon.targetScale - polygon.scale) / (FRAMES / 3);
	
	if(arc4random() % 100 > 50)
		polygon.rotateLeft = TRUE;
	else
		polygon.rotateLeft = FALSE;
	
	[lock unlock];
}

- (void) removePolygon:(NSTimer*) theTimer
{
	[lock lock];
	
	GeometricObject *polygon  = theTimer.userInfo;
	polygon.isNew = TRUE;
	[polygons removeObject:polygon];
	[dieingPolygons addObject:polygon];
	[physics destroyBody:(b2Body*)polygon.physicsData];
	
	[theTimer invalidate];
	polygon.timer = nil;
	
	polygon.scale = 1.f;
	polygon.targetScale = DISAPPEAR_SCALE;
	polygon.delta = (polygon.scale - polygon.targetScale) / (FRAMES / 2);
	
	[lock unlock];
}

- (void) render
{
	[lock lock];
	[physics step];
	NSNumber *uid;
	NSArray *keys = [touches allKeys];
	
	for(uid in keys)
	{
		InteractiveObject *spot = [touches objectForKey:uid];
		CGPoint pos = spot.position;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		glLoadIdentity();
		
		[spot renderCircularTouchWithSectors:SECTORS_TOUCH withWhite:FALSE];
		
		if(((spot.lastFramePosition.x == pos.x) && (spot.lastFramePosition.y == pos.y)))
		{
			if(spot.historyDepth > 0)
				spot.historyDepth -= 2;
			spot.framesStatic++;
		}
		
		if(((spot.lastFramePosition.x != pos.x) || (spot.lastFramePosition.y != pos.y)) && (spot.historyDepth < PREVIOUS_POSITION_QUEUE_DEPTH))
		{
			spot.historyDepth++;
			spot.framesStatic = 0;
		}
		
		spot.lastFramePosition = pos;
		
		int historyCount = [spot.positionHistoryQueue count] - 1;
		int depth = spot.historyDepth;
		
		float scale = 1.f;
		float step = 1.f / depth;
		CGPoint position;
		for(int i = 0; (i < historyCount) && (i < depth); i++)
		{
			position = [[spot.positionHistoryQueue objectAtIndex:historyCount - i] getCGPoint];		
			glLoadIdentity();
			glTranslated(position.x, position.y, 0.0);
			glScaled(scale, scale, 1.0);
			glTranslated(-position.x, -position.y, 0.0);
			scale -= step;
			
			[spot renderCircularTouchAtPosition:position withSectors:SECTORS_TOUCH withWhite:FALSE];
		}
		
	}
	
	for(GeometricObject *polygon in dieingPolygons)
	{
		if(polygon.isNew)
		{
			if((polygon.scale - polygon.delta) >= polygon.targetScale)
			{
				polygon.scale -= polygon.delta;
				
				glTranslated(polygon.position.x, polygon.position.y, 0.f);
				if(polygon.rotateLeft)
					glScaled(1.f, polygon.scale, 1.f);
				else
					glScaled(polygon.scale, 1.f, 1.f);
				glTranslated(-polygon.position.x, -polygon.position.y, 0.f);
				
			} else
			{
				glTranslated(polygon.position.x, polygon.position.y, 0.f);
				if(polygon.rotateLeft)
					glScaled(1.f, polygon.scale, 1.f);
				else
					glScaled(polygon.scale, 1.f, 1.f);
				glTranslated(-polygon.position.x, -polygon.position.y, 0.f);

				polygon.isNew = FALSE;
				polygon.scale = 1.f;
				polygon.targetScale = 0.f;
				polygon.delta = (polygon.scale - polygon.targetScale) / (FRAMES / 2);
			}
		} else 
		{
			if((polygon.scale - polygon.delta) >= polygon.targetScale)
			{
				polygon.scale -= polygon.delta;
				
				glTranslated(polygon.position.x, polygon.position.y, 0.f);
				if(polygon.rotateLeft)
					glScaled(polygon.scale, DISAPPEAR_SCALE, 1.f);
				else
					glScaled(DISAPPEAR_SCALE, polygon.scale, 1.f);
				glTranslated(-polygon.position.x, -polygon.position.y, 0.f);
				
			} else
			{
				[deadPolygons addObject:polygon];
				continue;
			}
		}

		[polygon render];
	}
	
	for(id object in deadPolygons)
	{
		[dieingPolygons removeObject:object];
	}
	[deadPolygons removeAllObjects];
	
	for(GeometricObject *polygon in polygons)
	{
		b2Body *body = (b2Body*) polygon.physicsData;
		
		CGPoint position = {body->GetPosition().x, body->GetPosition().y};
		polygon.position = position;
		polygon.angle = body->GetAngle() * RAD2DEG;

		glLoadIdentity();
		glTranslated(polygon.position.x, polygon.position.y, 0.f);
		glRotated(polygon.angle, 0.f, 0.f, 1.f);
		glTranslated(-polygon.position.x, -polygon.position.y, 0.f);
		
		if(polygon.isNew)
		{
			if((polygon.scale + polygon.delta) <= polygon.targetScale)
			{
				polygon.scale += polygon.delta;
				glTranslated(polygon.position.x, polygon.position.y, 0.f);
				
				if(polygon.rotateLeft)
					glScaled(polygon.scale, 1, 1);
				else
					glScaled(1, polygon.scale, 1);

				glTranslated(-polygon.position.x, -polygon.position.y, 0.f);
			} else 
			{
				polygon.isNew = FALSE;
			}

		} else 
		{
			if((body->IsSleeping()) && (!polygon.timer))
			{
				NSTimer *deathTimer = [NSTimer scheduledTimerWithTimeInterval:25.0
																	   target:self
																	 selector:@selector(removePolygon:)
																	 userInfo:polygon
																	  repeats:NO];
				polygon.timer = deathTimer;
			}
			else if((!body->IsSleeping()) && (polygon.timer))
			{
				[polygon.timer invalidate];
				polygon.timer = nil;
			}
		}

		
		[polygon render];
	}
	
	[lock unlock];
}
@end
