//
//  TUIOppListener.cpp
//  Finger
//
//  Created by Mood on 9/23/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#include "TUIOppListener.h"

TUIOppListener::TUIOppListener(int aPort)
{
	port = aPort;
	tuioClient = new TUIO::TuioClient(port);
	tuioClient->addTuioListener(this);
	tuioClient->connect();
}

void TUIOppListener::setMultiplexor(TuioMultiplexor *aMultiplexor)
{
	multiplexor = aMultiplexor;
}

TUIOppListener::~TUIOppListener()
{
	tuioClient->disconnect();
	delete tuioClient;
}

void TUIOppListener::addTuioObject(TUIO::TuioObject *tobj) 
{	
}

void TUIOppListener::updateTuioObject(TUIO::TuioObject *tobj) 
{	
}

void TUIOppListener::removeTuioObject(TUIO::TuioObject *tobj) 
{
}

void TUIOppListener::addTuioCursor(TUIO::TuioCursor *tcur) 
{	
	long offset = port - 3333;
	
	CGPoint position = {tcur->getX(), tcur->getY()};
	if((position.x == 0) && (position.y == 0))
		return;
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithLong:((long)tcur->getSessionID()) + (offset * 10000000)] withType:TouchDown atPos:position];

	lastPositions[tcur->getSessionID()] = position;
	
	[multiplexor cursorAddedEvent:event];	
}

void TUIOppListener::updateTuioCursor(TUIO::TuioCursor *tcur) 
{
	long offset = port - 3333;
	
	CGPoint position = {tcur->getX(), tcur->getY()};
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithLong:((long)tcur->getSessionID()) + (offset * 10000000)] withType:TouchMove atPos:position];
	
	event.lastPos = lastPositions[tcur->getSessionID()];
	
	if((position.x == 0) && (position.y == 0))
	{
		event.pos = event.lastPos;
	}
	else
	{
		lastPositions[tcur->getSessionID()] = position;
	}
	
	[multiplexor cursorUpdatedEvent:event];
}

void TUIOppListener::removeTuioCursor(TUIO::TuioCursor *tcur) 
{
	long offset = port - 3333;
	
	CGPoint position = {tcur->getX(), tcur->getY()};
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithLong:((long)tcur->getSessionID()) + (offset * 10000000)] withType:TouchRelease atPos:position];
	
	if((position.x == 0) && (position.y == 0))
	{
		event.pos = event.lastPos;
	}
	
	[multiplexor cursorRemovedEvent:event];
}

void TUIOppListener::refresh(TUIO::TuioTime packetTime)
{
}