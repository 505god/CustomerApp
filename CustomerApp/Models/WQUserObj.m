//
//  WQUserObj.m
//  App
//
//  Created by 邱成西 on 15/4/22.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQUserObj.h"


@implementation WQUserObj

+ (NSDictionary*)mts_mapping {
    return  @{@"userId": mts_key(userId),
              @"userName": mts_key(userName),
              @"userImg": mts_key(userHead),
              @"userPhone":mts_key(userPhone),
              };
}

+ (BOOL)mts_shouldSetUndefinedKeys {
    return NO;
}

@end
