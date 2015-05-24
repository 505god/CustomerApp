//
//  WQTabBarView.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/12.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WQTabBarItem.h"

//底部按钮类型
typedef enum{
    TabBarItemType_hot=0,
    TabBarItemType_class,
    TabBarItemType_search,
    TabBarItemType_chat,
    TabBarItemType_myself
}TabBarItemType;

@protocol WQTabBarViewDelegate;

@interface WQTabBarView : UIControl

//热卖
@property (nonatomic, weak) IBOutlet WQTabBarItem *hotItem;
//分类
@property (nonatomic, weak) IBOutlet WQTabBarItem *classItem;
//搜素
@property (nonatomic, weak) IBOutlet WQTabBarItem *searchItem;
//订单
@property (nonatomic, weak) IBOutlet WQTabBarItem *orderItem;
//个人中心
@property (nonatomic, weak) IBOutlet WQTabBarItem *myselfItem;

@property (nonatomic, assign) id<WQTabBarViewDelegate>delegate;

@property (nonatomic, assign) NSInteger currentPage;


//取消所有选中
-(void)defaultSelected;
@end

@protocol WQTabBarViewDelegate <NSObject>

-(void)tabBar:(WQTabBarView*)tabBarView selectedItem:(TabBarItemType)itemType;

@end