//
//  Connector.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "InteractiveObject.h"
#import "GlobalFunctions.h"
#import "ConnectionProtocol.h"

@interface Connection : NSObject <ConnectionProtocol>
{
	InteractiveObject *_endA;
	InteractiveObject *_endB;
	
	float _begin;
	float _end;
	
	bool _isReadyToDie;
	
}
@property InteractiveObject *endA;
@property InteractiveObject *endB;

@property(readonly) float length;
@property(readonly) float connectionAngle;

@property float begin;
@property float end;

@property bool isReadyToDie;

- (id) initWithendA:(InteractiveObject*) endA
			  endB:(InteractiveObject*) endB
		   beginningAt:(float) beginnning
			  endingAt:(float)ending;

- (float) length;
- (float) connectionAngle;
@end
