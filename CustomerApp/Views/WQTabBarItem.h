//
//  WQTabBarItem.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/12.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RKNotificationHub.h"

@interface WQTabBarItem : UIControl

@property (assign,nonatomic) BOOL isSelected;
///logo
@property (nonatomic, weak) IBOutlet UIImageView *logoImg;

@property (nonatomic, weak) IBOutlet UIView *whiteView;
@property (nonatomic, strong) RKNotificationHub *notificationHub;

@end
