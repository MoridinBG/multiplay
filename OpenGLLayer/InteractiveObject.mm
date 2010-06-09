//
//  InteractiveObject.mm
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/16/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "InteractiveObject.h"

@implementation InteractiveObject
#pragma mark Static Variables
static GLuint circleDisplayList;
static GLuint sensorDisplayList;
static GLuint rectangleDisplayList;
#pragma mark -

#pragma mark Synthesized Properties
@dynamic position;
@synthesize positionHistory = _positionHistory;
@synthesize velocity = _velocity;

@synthesize size = _size;
@dynamic angle;

@synthesize points = _points;
@synthesize pointsHistory = _pointsHistory;

@dynamic physicsData;

@synthesize type = _type;
@synthesize color = _color;
@synthesize uid = _uid;

@dynamic neighboursCount;
@dynamic connectedNeighboursCount;

@synthesize target = _target;
@synthesize stableTargetPosition = _stableTargetPosition;

@synthesize generalFlag = _generalFlag;
@synthesize frames = _frames;
@synthesize framesStatic = _framesStatic;
#pragma mark -

#pragma mark Class Methods for Statics

+ (GLuint) getCircleDisplayList
{
	if(!circleDisplayList)
	{
		circleDisplayList = glGenLists(1);
		glNewList(circleDisplayList,GL_COMPILE);
		
		int sections = 30;
		GLfloat radius = 0.5f;
		GLfloat twoPi = 2.0f * PI;
		
		glBegin(GL_TRIANGLE_FAN);
		glVertex2f(0.0f, 0.f);
		for(int i = 0; i <= sections; i++)
		{
			glVertex2f(radius * cos(i * twoPi / sections), 
					   radius * sin(i * twoPi / sections));
		}
		glEnd();
		
		glEndList();
	}
	
	return circleDisplayList;
}

+ (GLuint) getSensorDisplayList
{
	if(!sensorDisplayList)
	{
		sensorDisplayList = glGenLists(1);
		glNewList(sensorDisplayList, GL_COMPILE);
		
		GLfloat radius = 0.5f;
		glBegin(GL_LINE_LOOP);
		for (int i = 0; i < 20; i++)
		{
			float deg2rad = DEG2RAD;
			glVertex2f(cos(18 * i * deg2rad) * radius,
					   sin(18 * i * deg2rad) * radius);
		}
		glEnd();
		
		glEndList();
	}
	
	return sensorDisplayList;
}

+ (GLuint) getRectangleDisplayList
{
	if(!rectangleDisplayList)
	{
		rectangleDisplayList = glGenLists(1);
		glNewList(rectangleDisplayList, GL_COMPILE);
		
		glBegin(GL_QUADS);
		glVertex2f(-0.5f, -0.5f);
		glVertex2f(0.5f, -0.5f);
		glVertex2f(0.5f, 0.5f);
		glVertex2f(-0.5f, 0.5f);
		glEnd();
		
		glEndList();
	}
	
	return rectangleDisplayList;
}

#pragma mark -

#pragma mark Initialization
+ (id) interactiveFrom:(TuioBounds*)bounds
{
	InteractiveObject *interactive = [InteractiveObject alloc];
	if(interactive = [interactive initAtPosition:bounds.position
										 atAngle:bounds.angle * RAD2DEG
										withSize:bounds.dimensions])
	{
		interactive.uid = [bounds getKey];
		if(bounds.contour)
			interactive.points =  bounds.contour;
		if(bounds.contourHistory)
			interactive.pointsHistory = bounds.contourHistory;
		
		if((bounds.dimensions.width == 0.f) && (bounds.dimensions.height == 0.f))
			interactive.size = CGSizeMake(0.15f, 0.15f);
	}
	return interactive;
}

- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size
{
	if(self = [super init])
	{
		_position = position;
		_angle = angle;
		_size = size;
		
		_points = [[NSMutableArray alloc] init];

		_neighbours = [[NSMutableArray alloc] init];
		_connectedNeighbours = [[NSMutableDictionary alloc] init];
		
		_type = CIRCLE;
		if((arc4random() % 100) > 50)
			_generalFlag = true;
		else
			_generalFlag = false;
	}
	
	return self;
}

- (id) initAtPosition:(CGPoint)position
			  atAngle:(float)angle
			 withSize:(CGSize)size
	  physicsBackedBy:(b2Body*)physicsBody
			 withType:(Type)type;
{
	if(self = [self initAtPosition:position
						   atAngle:angle
						  withSize:size])
	{
		_physicsData = physicsBody;
		_type = type;
	}
	return self;
}

- (void) updateWithTuioBounds:(TuioBounds*)bounds
{
	self.position = bounds.position;
	self.positionHistory = bounds.movementHistory; //TODO: Check if assigment is neccessery
	self.angle = bounds.angle * RAD2DEG;
	self.size = bounds.dimensions;
	self.velocity = bounds.movementVelocity;
	self.points = bounds.contour;
}
#pragma mark -

#pragma mark Property Modifiers
- (void) setPosition:(CGPoint)position
{
	if(_physicsData)
		_position = position; //TODO: Apply force to the body to move it to this position
	else
	{
		if([_positionHistory count] >= HISTORY_DEPTH)
			[_positionHistory removeObjectAtIndex:0];
		[_positionHistory addObject:[[ObjectPoint alloc] initWithCGPoint:_position]];
		 
		_position = position;
	}
}

- (CGPoint) position
{
	if(_physicsData)
		return CGPointMake(_physicsData->GetPosition().x,
						   _physicsData->GetPosition().y);
	else
		return _position;
}

- (void) setAngle:(double)angle
{
	if(_physicsData)
		_angle = angle; //TODO: Apply rotational velocity to the given angle
	else 
		_angle = angle;
}


- (double) angle
{
	if(_physicsData)
		return _physicsData->GetAngle() * RAD2DEG;
	else
		return _angle;
}
#pragma mark -

#pragma mark Physics packing

- (void) setPhysicsData:(NSValue *)data
{
	if(_physicsData)
		_physicsData->GetWorld()->DestroyBody(_physicsData);
	_physicsData = (b2Body*) [data pointerValue];
}

- (NSValue*) physicsData
{
	return [NSValue valueWithPointer:_physicsData];
}

#pragma mark -

#pragma mark Manage Neighbours
- (void) addNeighbour:(InteractiveObject*)neighbour
{
	[_neighbours addObject:neighbour];
}

- (void) removeNeighbour:(InteractiveObject*)neigbour
{
	[_neighbours removeObject:neigbour];
}

- (void) connectTo:(InteractiveObject*)neighbour withConnection:(Connection*)connection;
{
	[_connectedNeighbours setObject:connection forKey:neighbour.uid];
}

- (Connection*) disconnectFrom:(InteractiveObject*)neighbour
{
	Connection *connection = [_connectedNeighbours objectForKey:neighbour.uid];
	[_connectedNeighbours removeObjectForKey:neighbour.uid];

	return connection;
}

- (bool) isConnectedToNeighbour:(InteractiveObject *)neighbour
{
	NSArray *connecteds = [_connectedNeighbours allKeys];
	return [connecteds containsObject:neighbour.uid];
}

- (int) neighboursCount
{
	return [_neighbours count];
}

- (int) connectedNeighboursCount
{
	return [_connectedNeighbours count];
}
#pragma mark -

#pragma mark Render
- (void) renderBasicShape
{
	glColor4f(_color.r, _color.g, _color.b, _color.a);
	glPushMatrix();
	glTranslated(self.position.x, self.position.y, 0.f);
	glRotated(self.angle, 0.f, 0.f, 1.f);
	glScaled(self.size.width, self.size.height, 1.f);

	switch(_type)
	{
		case CIRCLE:
		{
			glCallList([InteractiveObject getCircleDisplayList]);
		} break;
		case SENSOR:
		{
			glCallList([InteractiveObject getSensorDisplayList]);
		} break;
		case RECTANGLE:
		{
			glCallList([InteractiveObject getRectangleDisplayList]);
		} break;
		default:
		{
			[Logger logMessage:@"InteractiveObject doesn't have render type set!" ofType:DEBUG_ERROR];
		}
	}
	glPopMatrix();
}
#pragma mark -

#pragma mark Physics interaction
- (void) destroyPhysicsData
{
	if (_physicsData) 
	{
		_physicsData->GetWorld()->DestroyBody(_physicsData);
	}
	else if(DEBUG_ERROR_STATE)
	{
		[Logger logMessage:@"No physics data to destroy in this body!" ofType:DEBUG_ERROR];
	}
}
#pragma mark -
@end
