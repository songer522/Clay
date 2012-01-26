//
//  DlcGameWindow.h
//  Clay
//
//  Created by Brian Cable on 1/25/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "GameWindow.h"

typedef enum {
    DLC_CONTENT_LEVEL_TRAINING_RUN = 12,
    DLC_CONTENT_LEVEL_DOJO_RUN = 13
}DlcContentType;

#define kInAppPurchaseTrainingRunProductId @"com.xecudev.Clay.trainingLevelUnlock"
#define kInAppPurchaseDojoRunProductId @"com.xecudev.Clay.dojoLevelUnlock"

@interface DlcGameWindow : GameWindow

{
    Sprite *miniScreenshot1;
    Sprite *miniScreenshot2;
    
    bool _showingErrorWindow;
    
}

+(id)dlcGameWindowForContent:(DlcContentType)content;

-(id)initForContent:(DlcContentType)content;


@end
