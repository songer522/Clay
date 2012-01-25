//
//  InAppPurchaseManager.m
//  Clay
//
//  Created by Brian Cable on 1/24/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "InAppPurchaseManager.h"

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
        NSLog(@"Product title: %@" , product.localizedTitle);
        NSLog(@"Product description: %@" , product.localizedDescription);
        NSLog(@"Product price: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);        
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [_productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

@end
