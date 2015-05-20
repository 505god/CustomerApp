//
//  WQCustomerOrderObj.m
//  App
//
//  Created by 邱成西 on 15/4/15.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQCustomerOrderObj.h"

@implementation WQCustomerOrderObj
+ (NSDictionary*)mts_mapping {
    return  @{@"orderId": mts_key(orderId),
              @"orderTime": mts_key(orderTime),
              @"orderPrice": mts_key(orderPrice),
              @"orderStatus": mts_key(orderStatus),
              
              @"customerId": mts_key(customerId),
              @"customerName": mts_key(customerName),
              
              @"orderId": mts_key(productId),
              @"orderTime": mts_key(productImg),
              @"orderPrice": mts_key(productColor),
              @"orderCode": mts_key(productSize),
              @"orderStatus": mts_key(productName),
              @"orderId": mts_key(productPrice),
              @"orderTime": mts_key(productNumber),
              @"orderPrice": mts_key(productSaleType),
              @"orderCode": mts_key(productDiscount),
              @"orderStatus": mts_key(productReducePrice),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
