//
//  Connector.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GLContentLayer.h"
#import "b2Physics.h"

#import "ProximitySensorListener.h"
#import "ContactDetector.h"
#import "Connection.h"

#import "TremorsConnectionDrawer.h"
#import "LightningConnection.h"

@interface Connector : GLContentLayer <ProximitySensorListener>
{
	b2Physics *physics;
	ContactDetector *contactDetector;
	NSMutableArray *connections;
	NSMutableDictionary *sensors;
}

- (id) init;

- (void) tuioBoundsAdded: (TuioBounds*) newBounds;
- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds;

- (void) addEffectFilter;

- (void) drawGL;
@end
