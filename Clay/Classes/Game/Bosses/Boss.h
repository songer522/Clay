//
//  Boss.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BossProtocol <NSObject>

-(void)startBoss;

@end

@interface Boss : NSObject<BossProtocol>
{
    bool _isActive;
}

@property(nonatomic,assign)bool isActive;


+(id)instance;

@end
