//
//  GameCharacter.h
//  Clay
//
//  Created by Dustin Werner on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface GameCharacter : CCSprite

-(CCAnimationCache*)loadPlistForObjectName:(NSString*)objectName;
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andObjectName:(NSString*)objectName;

@end
