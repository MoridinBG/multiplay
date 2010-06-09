//
//  InteractiveObject.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/16/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "RGBA.h"
#import "consts.h"
#import "Logger.h"
#import "TUIO/TuioBounds.h"

#ifdef __cplusplus
	#import "Box2D/Dynamics/b2Body.h"
	#import "Box2D/Dynamics/b2World.h"
#endif

typedef enum type {CIRCLE, ELIPSE, RECTANGLE, SENSOR} Type;

@class Connection;
@interface InteractiveObject : NSObject
{
	CGPoint _position;
	NSMutableArray *_positionHistory;
	CGPoint _velocity;
	
	CGSize _size;
	double _angle;
	
	NSMutableArray *_points;
	NSMutableArray *_pointsHistory;

#ifdef __cplusplus
	b2Body *_physicsData;
#endif
	
	Type _type;
	RGBA *_color;
	NSNumber *_uid;
	
	NSMutableArray *_neighbours;
	NSMutableDictionary *_connectedNeighbours;
	
	InteractiveObject *_target;
	CGPoint _stableTargetPosition;
	
	BOOL _generalFlag;
	int _frames;
	int _framesStatic;
}
@property CGPoint position;
@property(assign) NSMutableArray* positionHistory;
@property CGPoint velocity;

@property CGSize size;
@property double angle;

@property(assign) NSMutableArray *points;
@property(assign) NSMutableArray *pointsHistory;

@property(assign) NSValue *physicsData;

@property Type type;
@property RGBA *color;
@property(assign) NSNumber *uid;

@property(readonly) int neighboursCount;
@property(readonly) int connectedNeighboursCount;

@property(assign) InteractiveObject *target;
@property CGPoint stableTargetPosition;

@property BOOL generalFlag;
@property int frames;
@property int framesStatic;

+ (GLuint) getCircleDisplayList;
+ (GLuint) getSensorDisplayList;
+ (GLuint) getRectangleDisplayList;

+ (id) interactiveFrom:(TuioBounds*)bounds;

- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size;

#ifdef __cplusplus
- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size
	  physicsBackedBy:(b2Body*)physicsBody
			 withType:(Type)type;
#endif

- (void) updateWithTuioBounds:(TuioBounds*)bounds;

- (void) addNeighbour:(InteractiveObject*)neighbour;
- (void) removeNeighbour:(InteractiveObject*)neigbour;

- (void) connectTo:(InteractiveObject*)neighbour withConnection:(Connection*)connection;
- (Connection*) disconnectFrom:(InteractiveObject*)neighbour;
- (bool) isConnectedToNeighbour:(InteractiveObject*)neighbour;

- (void) renderBasicShape;

- (void) destroyPhysicsData;
@end
