//
//  WQNavBarView.h
//  App
//
//  Created by 邱成西 on 15/3/20.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @author 邱成西, 15-03-20 18:03:38
 *
 *  导航栏
 */

@protocol WQNavBarViewDelegate;

@interface WQNavBarView : UIView

//title
@property (nonatomic, strong) UILabel *titleLab;

//左侧按钮
@property (nonatomic, strong) UIButton *leftBtn;

//右侧按钮
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) NSString *titleString;

@property (nonatomic, assign) BOOL isShowShadow;

@property (nonatomic, assign) id<WQNavBarViewDelegate>navDelegate;

@property (nonatomic, strong) UIImageView *lineView;
@end

@protocol WQNavBarViewDelegate <NSObject>

@optional

-(void)rightBtnClickByNavBarView:(WQNavBarView *)navView;

-(void)leftBtnClickByNavBarView:(WQNavBarView *)navView;
@end