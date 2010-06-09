//
//  TuioPointer.h
//  TUIO
//
//  Created by Ivan Dilchovski on 3/25/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TuioContainer.h"


@interface TuioPointer : TuioContainer
{
	unsigned int _tuID;
	unsigned int _cID;
	float _width;
	float _press;

}

- (id) initWithID:(unsigned int)sID
	   typeUserID:(unsigned int)tuID
	  componentID:(unsigned int)cID
		 position:(CGPoint)pos
 movementVelocity:(CGPoint)moveVelocity
	movementAccel:(float)moveAccel
			width:(float)width
			press:(float)press
		   atTime:(uint64_t)time;

@property unsigned int tuID;
@property unsigned int cID;
@property float width;
@property float press;

@end
