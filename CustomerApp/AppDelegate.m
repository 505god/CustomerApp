//
//  AppDelegate.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/10.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "AppDelegate.h"
#import <SMS_SDK/SMS_SDK.h>
#import "WQInitVC.h"
#import "Reachability.h"

#import "WQLogVC.h"
#import "JSONKit.h"
#import "WQLocalDB.h"

#import "WQMainVC.h"
#import "WQHotSaleVC.h"
#import "WQClassifyVC.h"
#import "WQSearchVC.h"
#import "WQOrderVC.h"
#import "WQMyselfVC.h"

#import "WQProductDetailVC.h"

@interface AppDelegate ()<ChatDelegate>

@property (strong, nonatomic) Reachability *hostReach;//网络监听所用
@end

@implementation AppDelegate
+ (AppDelegate *)shareIntance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //statusBar
    if (Platform>=7.0) {
        [WQDataShare sharedService].statusHeight = 20;
    }else {
        [WQDataShare sharedService].statusHeight = 0;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    [APService setupWithOption:launchOptions];
    
    
    //短信
    [SMS_SDK registerApp:@"46c880df3c3f" withSecret:@"e5d8a4bb450b2e2f2076bffdf57b2ec7"];
    [SMS_SDK enableAppContactFriends:NO];
    
    //开启网络状况的监听
    _isReachable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
    [_hostReach startNotifier];  //开始监听，会启动一个run loop
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    WQInitVC *initVC = [[WQInitVC alloc]init];
    self.navControl = [[UINavigationController alloc]initWithRootViewController:initVC];
    self.window.rootViewController = self.navControl;
    
    //获取未读信息
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *path = [Utility returnPath];
    NSString *filenameMessage = [path stringByAppendingPathComponent:@"message.plist"];
    if (![fileManage fileExistsAtPath:filenameMessage]) {
        [WQDataShare sharedService].messageArray = [NSMutableArray arrayWithCapacity:0];
    }else {
        NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:filenameMessage];
        [WQDataShare sharedService].messageArray = [NSMutableArray arrayWithArray:arr];
        SafeRelease(arr);
    }
    SafeRelease(filenameMessage);
    SafeRelease(path);
    
    [WQDataShare sharedService].idRegister = [[[NSUserDefaults standardUserDefaults] objectForKey:@"register"]boolValue];
    [self getCurrentLanguage];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.xmppManager goOffline];
    [self.xmppManager teardownStream];
    self.xmppManager = nil;
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *path = [Utility returnPath];
    //保存未读消息的数组
    NSString *filenameMessage = [path stringByAppendingPathComponent:@"message.plist"];
    if ([fileManage fileExistsAtPath:filenameMessage]) {
        [fileManage removeItemAtPath:filenameMessage error:nil];
    }
    [NSKeyedArchiver archiveRootObject:[WQDataShare sharedService].messageArray toFile:filenameMessage];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
#pragma mark - 获取当前语言
- (void)getCurrentLanguage {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage isEqualToString:@"zh-Hans"] || [currentLanguage isEqualToString:@"zh-Hant"]) {//汉语
        currentLanguage = @"zh";
    }else if ([currentLanguage isEqualToString:@"en"]) {//英语
    }else if ([currentLanguage isEqualToString:@"it"]) {//意大利语
    }else {
        currentLanguage = @"en";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ///语言
        [[WQAPIClient sharedClient] POST:@"/rest/login/langType" parameters:@{@"language":currentLanguage} success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        }];
    });
}
#pragma mark - 网络
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    if(status == NotReachable) {
        self.isReachable = NO;
    }else {
        self.isReachable = YES;
    }
}

#pragma mark - 加载RootViewController
-(void)showRootVC {
    [[WQLocalDB sharedWQLocalDB] getLocalUserDataWithCompleteBlock:^(NSArray *array) {
        if (array.count==0) {//未登录
            WQLogVC *logVC = [[WQLogVC alloc]init];
            self.navControl = [[UINavigationController alloc]initWithRootViewController:logVC];
            self.window.rootViewController = self.navControl;
            SafeRelease(logVC);
            
        }else {//已登录
            [WQDataShare sharedService].userObj = (WQUserObj *)[array firstObject];
            
            [[WQLocalDB sharedWQLocalDB] getLocalStroeDataWithCompleteBlock:^(NSArray *array) {
                if (array.count==0) {
                    [WQDataShare sharedService].userObj = nil;
                    
                    WQLogVC *logVC = [[WQLogVC alloc]init];
                    self.navControl = [[UINavigationController alloc]initWithRootViewController:logVC];
                    self.window.rootViewController = self.navControl;
                    SafeRelease(logVC);
                }else {
                    [WQDataShare sharedService].storeObj = (WQStoreObj *)[array firstObject];
                    
                    //登录成功之后连接XMPP
                    self.xmppManager = [WQXMPPManager sharedInstance];
                    
                    [self.xmppManager setupStream];
                    self.xmppManager.chatDelegate = self;
                    //xmpp连接
                    if (![self.xmppManager.xmppStream isConnected]) {
                        [self.xmppManager myConnect];
                    }
                    
                    WQMainVC *mainVC = [[WQMainVC alloc]init];
                    WQHotSaleVC *hotVC = [[WQHotSaleVC alloc]init];
                    WQClassifyVC *classifyVC = [[WQClassifyVC alloc]init];
                    WQSearchVC *searchVC = [[WQSearchVC alloc]init];
                    WQOrderVC *orderVC = [[WQOrderVC alloc]init];
                    WQMyselfVC *myselfVC = [[WQMyselfVC alloc]init];
                    
                    mainVC.childenControllerArray = @[hotVC,classifyVC,searchVC,orderVC,myselfVC];
                    
                    [mainVC setCurrentPageVC:0];
                    self.navControl = [[UINavigationController alloc]initWithRootViewController:mainVC];
                    
                    self.window.rootViewController = self.navControl;
                    SafeRelease(hotVC);SafeRelease(classifyVC);SafeRelease(orderVC);SafeRelease(myselfVC);SafeRelease(mainVC);SafeRelease(searchVC);
                }
            }];
        }
    }];
}

#pragma mark - chatDelegate
-(void)getNewMessage:(WQXMPPManager *)xmppManager Message:(XMPPMessage *)message {
    XMPPJID *fromJid = message.from;
    
    NSDictionary *aDic = [message.body objectFromJSONString];
    WQMessageObj *messageObj = [WQMessageObj messageFromDictionary:aDic];
    
    [[WQLocalDB sharedWQLocalDB] saveMessageToLocal:messageObj completeBlock:^(BOOL finished) {
    }];
    
    if ([WQDataShare sharedService].isInMessageView) {
        if ([[fromJid bare] isEqualToString:[WQDataShare sharedService].otherJID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetNewMessage" object:messageObj userInfo:nil];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isNewMessage" object:@"1" userInfo:nil];
            
            NSString *str = [NSString stringWithFormat:@"%d",messageObj.messageFrom];
            if (![[WQDataShare sharedService].messageArray containsObject:str]) {
                [[WQDataShare sharedService].messageArray addObject:str];
            }
        }
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNewMessage" object:@"1" userInfo:nil];
        
        NSString *str = [NSString stringWithFormat:@"%d",messageObj.messageFrom];
        if (![[WQDataShare sharedService].messageArray containsObject:str]) {
            [[WQDataShare sharedService].messageArray addObject:str];
        }
    }
}

-(void)didSendMessage:(WQXMPPManager *)xmppManager Message:(XMPPMessage *)message {
    NSDictionary *aDic = [message.body objectFromJSONString];
    WQMessageObj *messageObj = [WQMessageObj messageFromDictionary:aDic];
    
    [[WQLocalDB sharedWQLocalDB] saveMessageToLocal:messageObj completeBlock:^(BOOL finished) {
    }];
    
    if ([WQDataShare sharedService].isInMessageView) {
        XMPPJID *fromJid = message.to;
        if ([[fromJid bare] isEqualToString:[WQDataShare sharedService].otherJID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SendNewMessage" object:messageObj userInfo:nil];
        }else {
            //do nothing
        }
    }
}
-(void)senMessageFailed:(WQXMPPManager *)xmppManager Message:(XMPPMessage *)message {
    DLog(@"send message error");
}

@end
