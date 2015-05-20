//
//  WQSelectedProObj.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/17.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WQSelectedProObj : NSObject

@property (nonatomic, assign) NSInteger colorId;
@property (nonatomic, strong) NSString *colorName;

@property (nonatomic, assign) NSInteger sizeId;
@property (nonatomic, strong) NSString *sizeName;

@property (nonatomic, assign) NSInteger number;
@end
