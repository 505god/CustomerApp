//
//  WQPropertyVC.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/17.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "BaseViewController.h"
#import "WQProductObj.h"

#import "WQSelectedProObj.h"
@protocol WQPropertyVCDelegate;

@interface WQPropertyVC : BaseViewController

@property (nonatomic, strong) WQProductObj *productObj;

//选择的优惠
@property (nonatomic, strong) WQSelectedProObj *selectedPro;
@property (nonatomic, strong) WQSelectedProObj *proObj;

@property (nonatomic, strong) id<WQPropertyVCDelegate>delegate;
@end

@protocol WQPropertyVCDelegate <NSObject>

-(void)selectedProProperty:(WQSelectedProObj *)property;
@end