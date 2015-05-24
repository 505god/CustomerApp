//
//  WQHotSaleVC.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/12.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQHotSaleVC.h"
#import "WQProductObj.h"
#import "WQHotSaleCell.h"

#import "MJRefresh.h"
#import "WQProductDetailVC.h"

@interface WQHotSaleVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

///当前页开始索引
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger lastProductId;
///分页基数---默认10
@property (nonatomic, assign) NSInteger limit;
///总页数
@property (nonatomic, assign) NSInteger pageCount;
///加载更多
@property (nonatomic, assign) BOOL isLoadingMore;

@end

@implementation WQHotSaleVC

-(void)dealloc {
    SafeRelease(_collectionView.delegate);
    SafeRelease(_collectionView.dataSource);
    SafeRelease(_collectionView);
    SafeRelease(_dataArray);
}
#pragma mark - 获取产品列表

-(void)getProductList {
    __unsafe_unretained typeof(self) weakSelf = self;
    self.interfaceTask = [[WQAPIClient sharedClient] GET:@"/rest/product/getHostProduct" parameters:@{@"lastProductId":[NSNumber numberWithInteger:self.lastProductId],@"count":[NSNumber numberWithInteger:self.limit]} success:^(NSURLSessionDataTask *task, id responseObject) {
        if (weakSelf.isLoadingMore==NO) {
        weakSelf.dataArray = nil;
        }
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)responseObject;
            
            if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                NSDictionary *aDic = [jsonData objectForKey:@"returnObj"];
                NSArray *postsFromResponse = [aDic objectForKey:@"resultList"];
                
                NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
                
                for (NSDictionary *attributes in postsFromResponse) {
                    WQProductObj *product = [[WQProductObj alloc]init];
                    [product mts_setValuesForKeysWithDictionary:attributes];
                    [mutablePosts addObject:product];
                    SafeRelease(product);
                }
                
                NSInteger proNumber = [[aDic objectForKey:@"totalProduct"]integerValue];
                
                if (weakSelf.pageCount<0) {
                    weakSelf.pageCount = proNumber;
                }
                
                [weakSelf.dataArray addObjectsFromArray:mutablePosts];

                if ((weakSelf.start+weakSelf.limit)<weakSelf.pageCount) {
                    if (weakSelf.isLoadingMore == NO) {
                        [weakSelf addFooter];
                    }
                }else {
                    [weakSelf.collectionView removeFooter];
                }
            }else {
                weakSelf.start = (weakSelf.start-weakSelf.limit)<0?0:weakSelf.start-weakSelf.limit;
                [WQPopView showWithImageName:@"picker_alert_sigh" message:[jsonData objectForKey:@"msg"]];
            }
        }
        [weakSelf.collectionView reloadData];
        [weakSelf checkDataArray];
        [weakSelf.collectionView headerEndRefreshing];
        [weakSelf.collectionView footerEndRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.start = (weakSelf.start-weakSelf.limit)<0?0:weakSelf.start-weakSelf.limit;
        [weakSelf.collectionView headerEndRefreshing];
        [weakSelf.collectionView footerEndRefreshing];
        [weakSelf checkDataArray];
        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"InterfaceError", @"")];
    }];
}

-(void)checkDataArray {
    if (self.dataArray.count==0) {
        [self setNoneText:NSLocalizedString(@"NoneProducts", @"") animated:YES];
        [self setToolImage:@"" text:NSLocalizedString(@"NewProductVC", @"") animated:YES];
    }else {
        [self setNoneText:nil animated:NO];
        [self setToolImage:@"" text:NSLocalizedString(@"NewProductVC", @"") animated:NO];
    }
}
#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    [self.navBarView setTitleString:NSLocalizedString(@"HotSaleVC", @"")];
    [self.navBarView.rightBtn setHidden:YES];
    [self.navBarView.leftBtn setHidden:YES];
    [self.view addSubview:self.navBarView];
    
    self.limit = 10;
    
    //集成刷新控件
    [self addHeader];
    
    [self.collectionView headerBeginRefreshing];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [WQAPIClient cancelConnection];
    [self.interfaceTask cancel];
    self.interfaceTask = nil;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)addHeader {
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.collectionView addHeaderWithCallback:^{
        
        weakSelf.start = 0;
        weakSelf.lastProductId = 0;
        weakSelf.pageCount = -1;
        weakSelf.isLoadingMore = NO;
        [weakSelf.collectionView removeFooter];
        
        [weakSelf getProductList];
    } dateKey:@"WQHotSaleVC"];
}

- (void)addFooter {
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.collectionView addFooterWithCallback:^{
        weakSelf.start += weakSelf.limit;
        if (weakSelf.dataArray.count>0) {
            WQProductObj *proObj = (WQProductObj *)[weakSelf.dataArray lastObject];
            weakSelf.lastProductId = proObj.proId;
        }
        weakSelf.isLoadingMore = YES;
        [weakSelf getProductList];
    }];
}

#pragma mark - property
-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}
-(UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.navBarView.bottom, self.view.width, self.view.height-self.navBarView.height) collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[WQHotSaleCell class] forCellWithReuseIdentifier:@"WQHotSaleCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        [self.view insertSubview:_collectionView belowSubview:self.navBarView];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WQHotSaleCell *cell = (WQHotSaleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WQHotSaleCell" forIndexPath:indexPath];
    [cell setIndexPath:indexPath];
    
    if (self.dataArray.count>0) {
        WQProductObj *proObj = (WQProductObj *)self.dataArray[indexPath.item];
        [cell setProductObj:proObj];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.width/2, self.view.width/2+60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __block UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
        cell.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            WQProductDetailVC *detailVC = [[WQProductDetailVC alloc]init];
            
            WQProductObj *proObj = (WQProductObj *)self.dataArray[indexPath.item];
            detailVC.productObj = proObj;
            [self.navigationController pushViewController:detailVC animated:YES];
            SafeRelease(detailVC);
        }];
    }];
}

@end
