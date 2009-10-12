//
//  TUIOppListener.h
//  Finger
//
//  Created by Mood on 9/23/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//
#ifndef QTUIOLISTENER_H
#define QTUIOLISTENER_H

#import "TouchEvent.h"
#import "TuioMultiplexor.h"

#ifdef __cplusplus
#include "tuio/tuiolistener.h"
#include "tuio/tuioclient.h"
#include "tuio/TuioObject.h"
#include <map>



class  TUIOppListener : public TUIO::TuioListener
{
public:
	TUIOppListener(int aPort);
	~TUIOppListener();
	std::map<int, CGPoint> lastPositions;
	
	void addTuioObject(TUIO::TuioObject *tobj);
	void updateTuioObject(TUIO::TuioObject *tobj);
	void removeTuioObject(TUIO::TuioObject *tobj);
	
	void addTuioCursor(TUIO::TuioCursor *tcur);
	void updateTuioCursor(TUIO::TuioCursor *tcur);
	void removeTuioCursor(TUIO::TuioCursor *tcur);
	
	void refresh(TUIO::TuioTime packetTime);
	
	void setMultiplexor(TuioMultiplexor *aMultiplexor);
	
private:
	TUIO::TuioClient *tuioClient;
	TuioMultiplexor *multiplexor;
	
	int port;
};

#endif
#endif