//
//  WQStoreObj.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/15.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQStoreObj.h"

@implementation WQStoreObj

+ (NSDictionary*)mts_mapping {
    return  @{@"storeId": mts_key(storeId),
              @"storeName": mts_key(storeName),
              @"storeImg": mts_key(storeHead),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
