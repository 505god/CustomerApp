//
//  WQMainVC.m
//  App
//
//  Created by 邱成西 on 15/3/20.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQMainVC.h"

@interface WQMainVC ()<WQTabBarViewDelegate>

@end

@implementation WQMainVC

-(void)dealloc {
    SafeRelease(_tabBarView.delegate);
    SafeRelease(_childenControllerArray);
    SafeRelease(_currentViewController);
    SafeRelease(_tabBarView);
}

#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //设置tabBarView
    [self.view addSubview:self.tabBarView];
    self.tabBarView.currentPage = self.currentPage;
    
    //设置子controller
    self.currentViewController = [self.childenControllerArray objectAtIndex:self.currentPage];
    if (self.currentViewController) {
        [self addOneController:self.currentViewController];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNewMessage:) name:@"isNewMessage" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"isNewMessage" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - property
-(WQTabBarView *)tabBarView {
    if (!_tabBarView) {
        NSArray *bundles = [[NSBundle mainBundle] loadNibNamed:@"WQTabBarView" owner:self options:nil];
        _tabBarView = (WQTabBarView*)[bundles objectAtIndex:0];
        _tabBarView.delegate = self;
        [_tabBarView defaultSelected];
    }
    return _tabBarView;
}
-(void)setChildenControllerArray:(NSArray *)childenControllerArray{
    if (_childenControllerArray != childenControllerArray && childenControllerArray&& childenControllerArray.count > 0) {
        for (UIViewController *controller in childenControllerArray) {
            [controller willMoveToParentViewController:self];
            [self addChildViewController:controller];
            [controller didMoveToParentViewController:self];
        }
    }
    _childenControllerArray = childenControllerArray;
}


-(void)setCurrentPageVC:(NSInteger)page {
    if (self.currentPage != page) {
        [self.tabBarView defaultSelected];
        self.currentPage = page;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:self.currentPage]];
    }
}

#pragma mark - 子controller之间切换
-(void)addOneController:(UIViewController*)childController{
    if (!childController) {
        return;
    }
    [childController willMoveToParentViewController:self];
    childController.view.frame = (CGRect){0,0,self.view.width,self.view.height-NavgationHeight};
    [self.view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.tabBarView];
}

-(void)changeFromController:(UIViewController*)from toController:(UIViewController*)to{
    if (!from || !to) {
        return;
    }
    if (from == to) {
        return;
    }
    to.view.frame = (CGRect){0,0,self.view.width,self.view.height-NavgationHeight};
    [self transitionFromViewController:from toViewController:to duration:0 options:UIViewAnimationOptionTransitionNone animations:^{
        
    } completion:^(BOOL finished) {
        self.currentViewController = to;
        [self.view bringSubviewToFront:self.tabBarView];
    }];
}

#pragma mark - 底部代理

-(void)tabBar:(WQTabBarView*)tabBarView selectedItem:(TabBarItemType)itemType {
    if (itemType < self.childenControllerArray.count) {
        self.currentPage = itemType;
        [self changeFromController:self.currentViewController toController:[self.childenControllerArray objectAtIndex:itemType]];
    }
}

#pragma mark 通知
////消息
-(void)isNewMessage:(NSNotification *)notification
{
    NSInteger isNewMessage = [[notification object] integerValue];
    
    if (isNewMessage==1) {
        [self.tabBarView.myselfItem.notificationHub setCount:0];
        [self.tabBarView.myselfItem.notificationHub bump];
    }else {
        [self.tabBarView.myselfItem.notificationHub setCount:-1];
    }
}

@end
