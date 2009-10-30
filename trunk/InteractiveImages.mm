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
	if(self = [super init])
	{
		pictures = [[NSMutableArray alloc] initWithCapacity:15];
		NSError *error;
		NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
		
		for(NSString *filePath in files)
		{
			[Logger logMessage:[NSString stringWithFormat:@"Loading file %s", 
								[[directoryPath stringByAppendingString:filePath] cStringUsingEncoding:NSUTF8StringEncoding]] ofType:DEBUG_GENERAL];
			
			BasePicture *image = [[BasePicture alloc] initWithPath:[directoryPath stringByAppendingString:filePath]];
			if(!image)
			{
				[Logger logMessage:[NSString stringWithFormat:@"Skipping non PNG file %s", [filePath cStringUsingEncoding:NSUTF8StringEncoding]] ofType:DEBUG_GENERAL];
				continue;
			}
			image.scale = 0.1f;
			[pictures addObject:image];
		}
		shownPictures = [[NSMutableArray alloc] initWithCapacity:PICTURES_TO_SHOW];
		disappearingPictures = [[NSMutableArray alloc] initWithCapacity:PICTURES_TO_SHOW];
		deathTimers = [[NSMutableArray alloc] initWithCapacity:PICTURES_TO_SHOW];
		deadPictures = [[NSMutableArray alloc] initWithCapacity:PICTURES_TO_SHOW];
		
		pictureCreator = [NSTimer scheduledTimerWithTimeInterval:2.0
												 target:self
											   selector:@selector(showPicture:)
											   userInfo:nil
												repeats:YES];
	}
	
	return self;
}

- (void) showPicture:(NSTimer*) theTimer;
{
	[lock lock];
	if(([shownPictures count] + [disappearingPictures count]) == PICTURES_TO_SHOW)
	{
		[lock unlock];
		return;
	}
	
	int index = arc4random() % [pictures count];
	
	float x = ((arc4random() % 15) + 1) / 10.f;
	float y = ((arc4random() % 9) + 1) / 10.f;
	CGPoint position = {x, y};
	
	BasePicture *picture = [[pictures objectAtIndex:index] copy];
	picture.position = position;
	picture.delta = (picture.targetScale - picture.scale) / 10;
	picture.rotateDelta = 32.72f;
	
	[shownPictures addObject:picture];
	
	[lock unlock];
}

- (void) removePicture:(NSTimer*) theTimer
{
	[lock lock];

	BasePicture *picture = [theTimer userInfo];
	picture.targetScale = 0.1f;
	picture.delta = (picture.scale - picture.targetScale) / 20;
	float angularVelocity = ((b2Body*)picture.physicsData)->GetAngularVelocity() * RAD2DEG;
	if(angularVelocity > 0)
		picture.rotateLeft = TRUE;
	else if(angularVelocity < 0)
		picture.rotateLeft = FALSE;
	else if(angularVelocity == 0.f)
		picture.rotateLeft = !picture.rotateLeft;
	
	[shownPictures removeObject:picture];
	[disappearingPictures addObject:picture];
	[physics destroyBody:(b2Body*)picture.physicsData];
	picture.physicsData = nil;
	picture.rotateLeft = !picture.rotateLeft;
	
	[theTimer invalidate];
	[deathTimers removeObject:theTimer];
	
	[lock unlock];
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
	
	switch (event.type) 
	{
		case TouchDown:
		{
			InteractiveObject *touch = [[InteractiveObject alloc] initWithPos:pos];
			touch.physicsData = [physics createCirclularBodyWithRadius:TOUCH_PHYSICS_BODY_SIZE atPosition:pos];
			[physics attachMouseJointToBody:(b2Body*)touch.physicsData withId:uniqueID];
			
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
			
			[physics updateMouseJointWithId:uniqueID toPosition:pos];
			
		} break;
			
		case TouchRelease:
		{
			[physics detachMouseJointWithId:uniqueID];
			[physics destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	[physics step];
	for(BasePicture *picture in shownPictures)
	{
		b2Body *body = (b2Body*) picture.physicsData;
		if(!picture.isNew)
		{
			
			if((body->IsSleeping()) && (!body->GetUserData()))
			{
				NSTimer *deathTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
																	   target:self
																	 selector:@selector(removePicture:)
																	 userInfo:picture
																	  repeats:NO];
				body->SetUserData(deathTimer);
			}
			else if((!body->IsSleeping()) && (body->GetUserData()))
			{
				NSTimer *timer = (NSTimer*)body->GetUserData();
				[timer invalidate];
				body->SetUserData(NULL);
			}
		}
		CGPoint spiralAppear = {0.f, 0.f};
		if(picture.physicsData)
		{
			CGPoint pos = {body->GetPosition().x, body->GetPosition().y};
			picture.position = pos;
		}
		
		if(picture.isNew)
		{
			picture.angle += picture.rotateDelta;
			if ((picture.targetScale - picture.scale) >= picture.delta)
			{
				picture.scale += picture.delta;
			}
			else
			{
				picture.isNew = FALSE;
				picture.physicsData = (void*)[physics createRectangularBodyWithSize:picture.oglSize atPosition:picture.position rotatedAt:0];
			}
			spiralAppear.x = (picture.oglSize.width * picture.scale) / 2;
			spiralAppear.y = (picture.oglSize.height * picture.scale) / 2;
		} else
		{
			picture.angle = body->GetAngle() * RAD2DEG;
		}
		
		glLoadIdentity();
		glTranslated(picture.position.x, picture.position.y, 0);

		glTranslated(spiralAppear.x, spiralAppear.y, 0);
		glRotated(picture.angle, 0.f, 0.f, 1.f);
		glTranslated(-spiralAppear.x, -spiralAppear.y, 0);
		
		glScaled(picture.scale, picture.scale, 1.f);
		glTranslated(-picture.position.x, -picture.position.y, 0);		
		
		glBindTexture(GL_TEXTURE_2D, picture.texName);
		
		glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);
		glVertex2f(picture.position.x, picture.position.y);
		glTexCoord2f(1.0f, 0.0f);
		glVertex2f(picture.position.x + picture.oglSize.width, picture.position.y);
		glTexCoord2f(1.0f, 1.0f);
		glVertex2f(picture.position.x + picture.oglSize.width, picture.position.y + picture.oglSize.height);
		glTexCoord2f(0.0f, 1.0f);
		glVertex2f(picture.position.x, picture.position.y + picture.oglSize.height);
		glEnd();
	}
	
	for(BasePicture *picture in disappearingPictures)
	{
		CGPoint pos = picture.position;
		if(picture.rotateLeft)
			picture.angle += picture.rotateDelta;
		else
			picture.angle -= picture.rotateDelta;
		

		CGPoint spiralDisappear = {(picture.oglSize.width * picture.scale) / 2, (picture.oglSize.height * picture.scale) / 2};
		if ((picture.scale - picture.targetScale) >= picture.delta)
		{
			picture.scale -= picture.delta;
		}
		else
		{
			[deadPictures addObject:picture];
			[physics destroyBody:(b2Body*)picture.physicsData];
		}
		
		glLoadIdentity();
		glTranslated(picture.position.x, picture.position.y, 0);
		
		glTranslated(spiralDisappear.x, spiralDisappear.y, 0);
		glRotated(picture.angle, 0.f, 0.f, 1.f);
		glTranslated(-spiralDisappear.x, -spiralDisappear.y, 0);
		
		glScaled(picture.scale, picture.scale, 1.f);
		glTranslated(-picture.position.x, -picture.position.y, 0);		
		
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
		
	}
	
	if([deadPictures count])
	{
		for(BasePicture *picture in deadPictures)
			[disappearingPictures removeObject:picture];
		[deadPictures removeAllObjects];
	}
	[lock unlock];
}

@end
