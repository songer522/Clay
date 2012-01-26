//
//  InAppPurchaseManager.m
//  Clay
//
//  Created by Brian Cable on 1/24/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "SKProduct+LocalizedPrice.h"
#import "LayerManager.h"


@implementation InAppPurchaseManager

static InAppPurchaseManager *_shared = nil;

+(InAppPurchaseManager*)shared
{
	if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
	}
	return _shared;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [[self shared] retain];
}

-(id)copyWithZone:(NSZone*)zone
{
    return self;
}

-(id)retain
{
    return self;
}

-(NSUInteger)retainCount
{
    return NSUIntegerMax; //denotes an object that cannot be released
}

-(oneway void)release
{
    //do nothing
}

-(id)autorelease
{
    return self;
}

-(id)init
{
    if ((self=[super init])) {
        _dlcData = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}



- (void)requestProductData
{
    NSSet *productIdentifiers = [NSSet setWithObjects:@"com.xecudev.Clay.trainingLevelUnlock",@"com.xecudev.Clay.dojoLevelUnlock", nil];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    for (SKProduct *product in products) {
        [_dlcData setValue:[product retain] forKey:product.productIdentifier];
        /*
        NSLog(@"Product title: %@" , product.localizedTitle);
        NSLog(@"Product description: %@" , product.localizedDescription);
        NSLog(@"Product price: %@" , [product localizedPrice]);
        NSLog(@"Product id: %@" , product.productIdentifier);        
        */
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        [_delegate openErrorWindowCantConnectToStore];
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [_productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}




//
// call this method once on startup
//
- (void)loadStoreWithDelegate:(id<DlcLevelDelegate>)delegate
{
    _delegate = delegate;
    
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description
    [self requestProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

#pragma -
#pragma Purchase helpers

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                //NSLog(@"TRANSACTION PURCHASED");
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //NSLog(@"TRANSACTION FAILED");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                //NSLog(@"TRANSACTION RESTORED");
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}


-(SKProduct*)getProductInfoForKey:(NSString*)key
{
    SKProduct *product = [_dlcData objectForKey:key];
    return product;
}



#pragma mark -
#pragma mark Purchasing methods

//call these methods when user says they want to make the purchase


//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"RECORD TRANSACTION");
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseTrainingRunProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"trainingRunTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseDojoRunProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"dojoRunTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable features
//
- (void)provideContent:(NSString *)productId
{
    bool updateBonusLevelsMenu = false;
    
    if ([productId isEqualToString:kInAppPurchaseTrainingRunProductId])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isTrainingRunPurchased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        updateBonusLevelsMenu = true;
        NSLog(@"PROVIDE CONTENT: TRAINING RUN");
        [_delegate updateDlcLevels];

    }
    else if ([productId isEqualToString:kInAppPurchaseDojoRunProductId])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDojoRunPurchased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        updateBonusLevelsMenu = true;
        NSLog(@"PROVIDE CONTENT: DOJO RUN");
        [_delegate updateDlcLevels];
    }
    
    
    
}


- (void)purchaseProductId:(NSString*)productId Delegate:(id<DlcLevelDelegate>)delegate
{
    _delegate = delegate;
    
    if ([self canMakePurchases]) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];        
    } else {
        [_delegate openErrorWindowCantMakePurchases];
    }
}



@end
