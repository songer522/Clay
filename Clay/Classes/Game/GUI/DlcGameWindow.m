//
//  DlcGameWindow.m
//  Clay
//
//  Created by Brian Cable on 1/25/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "DlcGameWindow.h"
#import "InAppPurchaseManager.h"
#import "SKProduct+LocalizedPrice.h"
#import "LayerManager.h"

@implementation DlcGameWindow

+(id)dlcGameWindowForContent:(DlcContentType)content withLayer:(CCLayer*)layer
{
    return [[self alloc] initForContent:content withLayer:layer];
}

-(id)initForContent:(DlcContentType)content withLayer:(CCLayer*)layer
{
    SKProduct *productInfo = nil;
    
    _contentId = content;
    
    switch (content) {
        case DLC_CONTENT_LEVEL_DOJO_RUN:
            productInfo = [[InAppPurchaseManager shared] getProductInfoForKey:kInAppPurchaseDojoRunProductId];
            break;
        case DLC_CONTENT_LEVEL_TRAINING_RUN:
            productInfo = [[InAppPurchaseManager shared] getProductInfoForKey:kInAppPurchaseTrainingRunProductId];
            break;
        default:
            break;
    }
    
    if(productInfo!=nil) {
        self = [super initWithHeader:productInfo.localizedTitle Message:productInfo.localizedDescription Choices:WINDOW_CHOICE_YESNO Layer:layer];
        _showingErrorWindow = false;
    } else {
        self = [super initWithHeader:@"ERROR" Message:@"COULD NOT GET INFORMATION FROM THE STORE.|PLEASE TRY AGAIN LATER OR CONTACT SUPPORT." Choices:WINDOW_CHOICE_OK Layer:layer];
        _showingErrorWindow = true;
    }
    
    return self;
}

-(void)triggerPurchase
{
    switch (_contentId) {
        case DLC_CONTENT_LEVEL_TRAINING_RUN:
            [[InAppPurchaseManager shared] purchaseTrainingLevel];
            break;
        case DLC_CONTENT_LEVEL_DOJO_RUN:
            [[InAppPurchaseManager shared] purchaseDojoLevel];
            break;
        default:
            break;
    }
}


-(void) dealloc
{
    [miniScreenshot1 release];
    [miniScreenshot2 release];
    [super dealloc];
}

@end
