//
//  InAppPurchaseManager.h
//  Clay
//
//  Created by Brian Cable on 1/24/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//
//  Based on code from: http://troybrant.net/blog/2010/01/in-app-purchases-a-full-walkthrough/

#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

#define kInAppPurchaseTrainingRunProductId @"com.xecudev.Clay.trainingLevelUnlock"
#define kInAppPurchaseDojoRunProductId @"com.xecudev.Clay.dojoLevelUnlock"



@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *_productsRequest;
    
    SKProduct *_trainingLevelProduct;
    SKProduct *_dojoLevelProduct;
}

+(InAppPurchaseManager*)shared;
- (void)requestProductData;
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;

//transaction functions
- (void)loadStore;
- (BOOL)canMakePurchases;

#pragma mark -
#pragma mark Purchasing methods
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productId;
-(void)purchaseTrainingLevel;
-(void)purchaseDojoLevel;


@end
