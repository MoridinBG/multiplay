//
//  Connector.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Connector.h"


@implementation Connector

- (id) init
{
	if(self = [super init])
	{
		connections = [[NSMutableArray alloc] init];
		sensors = [[NSMutableDictionary alloc] init];
		
		physics = [[b2Physics alloc] init];
		contactDetector = [physics addContactDetector];
		contactDetector.effect = self;
		
//		[self addEffectFilter];
	}
	return self;
}

- (void) addEffectFilter
{
	CIFilter *bloom = [CIFilter filterWithName:@"CIBloom"];
	[bloom setDefaults];
	bloom.name = @"bloom";
	[self setFilters:[NSArray arrayWithObjects:bloom, nil]];
	
	[self setValue:[NSNumber numberWithFloat:5.0f]
		forKeyPath:[NSString stringWithFormat:@"filters.bloom.%@", kCIInputIntensityKey]];
	[self setValue:[NSNumber numberWithFloat:20.0f]
		forKeyPath:[NSString stringWithFormat:@"filters.bloom.%@", kCIInputRadiusKey]];
	
	
}

#pragma mark TUIO
- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	[super tuioBoundsAdded:newBounds];
	
	InteractiveObject *sensor = [physics createCircleSensorAtPosition:newBounds.position
															   withSize:CGSizeMake(1.4f, 0.8f)];
	sensor.uid = [newBounds getKey];
	sensor.color = (RGBA*)[[objects objectForKey:sensor.uid] color];
	[sensors setObject:sensor forKey:[newBounds getKey]];
	[physics attachMouseJointToBody:sensor.physicsData 
							 withId:[newBounds getKey]];
	
}

- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds
{
	[super tuioBoundsUpdated:updatedBounds];

	//TODO: Update sensor size based on contour size. Keep connection alive
	[physics updateMouseJointWithId:[updatedBounds getKey]
						 toPosition:updatedBounds.position];
}

- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds
{
	[super tuioBoundsRemoved:deadBounds];
	
	[physics detachMouseJointWithId:[deadBounds getKey]];
	[[sensors objectForKey:[deadBounds getKey]] destroyPhysicsData];
	[sensors removeObjectForKey:[deadBounds getKey]];
}
#pragma mark -

#pragma mark Render
- (void) drawGL
{
	[physics step];
	NSArray *keys = [objects allKeys];
	NSNumber *key;
	
	for(Connection *connection in connections)
	{
		[connection render];
	}
	
	for(key in keys)
	{
		InteractiveObject *body = [objects objectForKey:key];
		[body renderBasicShape];
		
		glColor3f(body.color.r, body.color.g, body.color.b);
		gluTessBeginPolygon(tess, NULL);
		gluTessBeginContour(tess);
		
		NSArray *contour = body.points;
		int count = [contour count];
		GLdouble vertices[count][3];
		for(int i = 0; i < count; i++)
		{
			ObjectPoint *point = [contour objectAtIndex:i];
			vertices[i][0] = point.x;
			vertices[i][1] = point.y;
			vertices[i][2] = 0.f;
			gluTessVertex(tess, vertices[i], vertices[i]);
		}
		
		gluTessEndContour(tess);
		gluTessEndPolygon(tess);
	}
}
#pragma mark -

#pragma mark Contact Handler
- (void) contactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj
{
	[firstObj addNeighbour:secondObj];
	[secondObj addNeighbour:firstObj];
	
	if((firstObj.connectedNeighboursCount < 4) && (secondObj.connectedNeighboursCount < 4))
		if(![firstObj isConnectedToNeighbour:secondObj])
		{
			LightningConnection *connection = [[LightningConnection alloc] initWithendA:firstObj
//			TremorsConnectionDrawer *connection = [[TremorsConnectionDrawer alloc] initWithendA:firstObj
																						  endB:secondObj
																					   beginningAt:0.f
																						  endingAt:1.f];
			
			[firstObj connectTo:secondObj withConnection:connection];
			[secondObj connectTo:firstObj withConnection:connection];
			
			[connections addObject:connection];
		}
}

- (void) removedContactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj
{
	[firstObj removeNeighbour:secondObj];
	[secondObj removeNeighbour:firstObj];
	
	if([firstObj isConnectedToNeighbour:secondObj])
	{
		Connection *connection = [firstObj disconnectFrom:secondObj];
		[secondObj disconnectFrom:firstObj];

		[connections removeObject:connection];
	}
}
#pragma mark -
@end
