//
//  AppDelegate.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/10.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WQXMPPManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navControl;

@property (nonatomic, strong) WQXMPPManager *xmppManager;
@property (assign, nonatomic) BOOL isReachable;//网络是否连接

+ (AppDelegate *)shareIntance;

-(void)showRootVC;
@end

