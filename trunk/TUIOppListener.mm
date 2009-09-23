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
	//qDebug() << "add obj " << tobj->getSymbolID() << " (" << tobj->getSessionID() << ") "<< tobj->getX() << " " << tobj->getY() << " " << tobj->getAngle();
	
}

void TUIOppListener::updateTuioObject(TUIO::TuioObject *tobj) 
{
	
	//qDebug() << "set obj " << tobj->getSymbolID() << " (" << tobj->getSessionID() << ") "<< tobj->getX() << " " << tobj->getY() << " " << tobj->getAngle() 
	//	<< " " << tobj->getMotionSpeed() << " " << tobj->getRotationSpeed() << " " << tobj->getMotionAccel() << " " << tobj->getRotationAccel();
	
}

void TUIOppListener::removeTuioObject(TUIO::TuioObject *tobj) 
{
	
	//qDebug() << "del obj " << tobj->getSymbolID() << " (" << tobj->getSessionID() << ")";
}

void TUIOppListener::addTuioCursor(TUIO::TuioCursor *tcur) 
{
	//	qDebug() << "add cur " << tcur->getCursorID() << " (" <<  tcur->getSessionID() << ") " << tcur->getX() << " " << tcur->getY();
	
	int offset = port - 3333;
	
	CGPoint position = {tcur->getX(), tcur->getY()};
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithUnsignedInt:tcur->getSessionID() + (offset * 10000000)] withType:TouchDown atPos:position];
	
	[multiplexor cursorAddedEvent:event];	
}

void TUIOppListener::updateTuioCursor(TUIO::TuioCursor *tcur) 
{
	//qDebug() << "set cur " << tcur->getCursorID() << " (" <<  tcur->getSessionID() << ") " << tcur->getX() << " " << tcur->getY() << " " << tcur->getMotionSpeed() << " " << tcur->getMotionAccel() << " ";
	int offset = port - 3333;
	
	CGPoint position = {tcur->getX(), tcur->getY()};
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithUnsignedInt:tcur->getSessionID() + (offset * 10000000)] withType:TouchMove atPos:position];
	
	[multiplexor cursorUpdatedEvent:event];
}

void TUIOppListener::removeTuioCursor(TUIO::TuioCursor *tcur) 
{
	//	qDebug() << "del cur " << tcur->getCursorID() << " (" <<  tcur->getSessionID() << ")";
	int offset = port - 3333;
	
	CGPoint position = {tcur->getX(), tcur->getY()};
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithUnsignedInt:tcur->getSessionID() + (offset * 10000000)] withType:TouchRelease atPos:position];
	
	[multiplexor cursorRemovedEvent:event];
}

void TUIOppListener::refresh(TUIO::TuioTime packetTime)
{
}