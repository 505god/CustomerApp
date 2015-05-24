//
//  WQOrderVC.m
//  App
//
//  Created by 邱成西 on 15/2/4.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQOrderVC.h"

#import "DAPagesContainer.h"

#import "WQOrderPayVC.h"
#import "WQOrderDeliveryVC.h"
#import "WQOrderReceivingVC.h"
#import "WQOrderFinishVC.h"

@interface WQOrderVC ()

//待处理、待付款、已完成容器
@property (strong, nonatomic) DAPagesContainer *pagesContainer;

@end

@implementation WQOrderVC

-(void)dealloc {
    SafeRelease(_pagesContainer);
}

#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstShow = YES;
    //导航栏
    [self.navBarView setTitleString:NSLocalizedString(@"OrderVC", @"")];
    [self.navBarView.rightBtn setHidden:YES];
    [self.navBarView.leftBtn setHidden:YES];
    [self.view addSubview:self.navBarView];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstShow) {
        [self initContainerView];
        self.isFirstShow= NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//商品类页面容器
-(void)initContainerView {
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = (CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height};
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
    
    //待付款
    WQOrderPayVC *payVC = [[WQOrderPayVC alloc]init];
    payVC.title = NSLocalizedString(@"orderPay", @"");
    
    //待发货
    WQOrderDeliveryVC *deliveryVC = [[WQOrderDeliveryVC alloc]init];
    deliveryVC.title = NSLocalizedString(@"DeliveryVC",@"");
    
    //待收货
    WQOrderReceivingVC *receivingVC = [[WQOrderReceivingVC alloc]init];
    receivingVC.title = NSLocalizedString(@"ReceivingVC",@"");
    
    //已关闭
    WQOrderFinishVC *finishVC = [[WQOrderFinishVC alloc]init];;
    finishVC.title = NSLocalizedString(@"orderFinish", @"");
    
    self.pagesContainer.viewControllers = @[payVC,deliveryVC,receivingVC,finishVC];
    SafeRelease(deliveryVC);SafeRelease(payVC);SafeRelease(finishVC);SafeRelease(receivingVC);
}


@end
