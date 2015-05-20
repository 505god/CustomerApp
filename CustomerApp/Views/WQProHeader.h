//
//  WQProHeader.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/14.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WQProHeaderDelegate;

@interface WQProHeader : UITableViewHeaderFooterView

@property (nonatomic, assign) id<WQProHeaderDelegate>delegate;

@property (nonatomic, strong) NSString *imageString;
@property (nonatomic, strong) NSArray *dataArray;

@end

@protocol WQProHeaderDelegate <NSObject>

@optional
-(void)imagePressedWithHeader:(WQProHeader *)header imgView:(UIImageView *)imgView atIndex:(NSInteger)index;
@end