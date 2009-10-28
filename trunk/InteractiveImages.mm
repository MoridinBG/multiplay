//
//  InteractiveImages.m
//  Finger
//
//  Created by Ivan Dilchovski on 10/22/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "InteractiveImages.h"


@implementation InteractiveImages

- (id) initWithPicturesInDirectory:(NSString*)directoryPath
{
	if(self = [super initWithPicturesInDirectory:directoryPath])
	{
		shownPictures = [[NSMutableArray alloc] initWithCapacity:15];
		
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self
											   selector:@selector(showPicture:)
											   userInfo:nil
												repeats:YES];
	}
	
	return self;
}

- (void)showPicture:(NSTimer*)theTimer
{
	if([shownPictures count] == [pictures count])
	{
		[timer invalidate];
		return;
	}
	
	int index = 0;
	do 
	{
		index = arc4random() % [pictures count];
	} while ([shownPictures containsObject:[pictures objectAtIndex:index]]);
	
	BasePicture *picture = [pictures objectAtIndex:index];
	CGPoint position = {0.8f, 0.5f};
	picture.physicsData = (void*)[physics createRectangularBodyWithSize:picture.oglSize atPosition:position];
	
	[shownPictures addObject:picture];
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
	NSLog(@"%f,%f %f,%f", pos.x, pos.y, lastPos.x, lastPos.y);
	
	switch (event.type) 
	{
		case TouchDown:
		{
			InteractiveObject *touch = [[InteractiveObject alloc] initWithPos:pos];
			touch.physicsData = [physics createCirclularBodyWithRadius:TOUCH_PHYSICS_BODY_SIZE atPosition:pos];
			
			[touches setObject:touch forKey:uniqueID];
		} break;
			
		case TouchMove:
		{
			b2Body* body = (b2Body*)[[touches objectForKey:uniqueID] physicsData];
			
			if(!body)
			{
				[lock unlock];
				return;
			}
			
//			if(body->IsSleeping())
//				body->WakeUp();
//			body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);
//			body->ApplyForce(b2Vec2(, <#const b2Vec2 point#>)
		} break;
			
		case TouchRelease:
		{
			[physics destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	[physics step];
	int i = 0;
	for(BasePicture *picture in shownPictures)
	{
		b2Body *body = (b2Body*) picture.physicsData;
		CGPoint pos = {body->GetPosition().x, body->GetPosition().y};
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0);
		glRotated((body->GetAngle() * RAD2DEG), 0, 0, 1);
		glTranslated(-pos.x, -pos.y, 0);
		
		glBindTexture(GL_TEXTURE_2D, picture.texName);
		glBegin(GL_QUADS);
		
		glTexCoord2f(0.0f, 0.0f);
		glVertex2f(pos.x, pos.y);
		
		glTexCoord2f(1.0f, 0.0f);
		glVertex2f(pos.x + picture.oglSize.width, pos.y);
		
		glTexCoord2f(1.0f, 1.0f);
		glVertex2f(pos.x + picture.oglSize.width, pos.y + picture.oglSize.height);
		
		glTexCoord2f(0.0f, 1.0f);
		glVertex2f(pos.x, pos.y + picture.oglSize.height);
		
		glEnd();
		i++;
	}
	[lock unlock];
}

@end
