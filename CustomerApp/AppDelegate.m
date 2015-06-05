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

#import "MobClick.h"

#import "PayPalMobile.h"
#import "BlockAlertView.h"

@interface AppDelegate ()<ChatDelegate>

@property (strong, nonatomic) Reachability *hostReach;//网络监听所用
@end

@implementation AppDelegate
+ (AppDelegate *)shareIntance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MobClick startWithAppkey:@"5569ec1e67e58e11b70037ee" reportPolicy:BATCH   channelId:@"Web"];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction:@"AR1knpV11rnwEJl3Po250TQzqcH3No8BVMJrTK5Qkf-_cz1BwGPQXf93iTxgab539AAg70tsDyM4DJOL",PayPalEnvironmentSandbox:@"AR0i2fqecL3yXFHdaMiiChWW_WfeVMgiXepg0AFMNm26nUX_TyU3HkjqNptCKK1T5BoplfEOt5314-LA"}];

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"isOn"];
    [defaults synchronize];
    
    //点击推送进入App
    NSDictionary *pushDict = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (pushDict) {
    }
    SafeRelease(pushDict);
    
    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:2 forKey:@"isOn"];
    [defaults synchronize];
    
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

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"isOn"];
    [defaults synchronize];
    
    [[WQLocalDB sharedWQLocalDB] getLocalUserDataWithCompleteBlock:^(NSArray *array) {
        if (array.count==0) {//未登录
        }else {//已登录
            [WQDataShare sharedService].userObj = (WQUserObj *)[array firstObject];
            
            [[WQLocalDB sharedWQLocalDB] getLocalStroeDataWithCompleteBlock:^(NSArray *array) {
                if (array.count==0) {
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
                }
            }];
        }
    }];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"isOn"];
    [defaults synchronize];
    
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
    
    NSInteger isOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"isOn"];
    int type = [[userInfo objectForKey:@"type"]intValue];
    
    if (type==0) {//异地登陆
        [[WQLocalDB sharedWQLocalDB] deleteLocalStroeWithCompleteBlock:nil];
        [[WQLocalDB sharedWQLocalDB] deleteLocalUserWithCompleteBlock:^(BOOL finished) {
            if (finished) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionCookies"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.xmppManager goOffline];
                [self.xmppManager teardownStream];
                self.xmppManager = nil;
                [WQDataShare sharedService].userObj = nil;
                [WQDataShare sharedService].storeObj = nil;
                
                [self showRootVC];
            }
        }];
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Alert Title" message:NSLocalizedString(@"ConfirmDelete", @"")];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"Confirm", @"") block:nil];
        [alert show];
    }
    
    
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
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        [self logIn];
                    });
                    
                    self.window.rootViewController = self.navControl;
                    SafeRelease(hotVC);SafeRelease(classifyVC);SafeRelease(orderVC);SafeRelease(myselfVC);SafeRelease(mainVC);SafeRelease(searchVC);
                }
            }];
        }
    }];
}
-(void)logIn {
    [[WQAPIClient sharedClient] POST:@"/rest/login/customerLogin" parameters:@{@"userPhone":[WQDataShare sharedService].userObj.userPhone,@"userPassword":[WQDataShare sharedService].userObj.password,@"validateCode":@""} success:^(NSURLSessionDataTask *task, id responseObject) {

        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://120.24.64.85:8443/rest/login/customerLogin"]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"sessionCookies"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

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
