//
//  WQProductDetailVC.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/14.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQProductDetailVC.h"

#import "ImgScrollView.h"

#import "WQProHeader.h"
#import "WQProCell.h"
#import "WQProDetailCell.h"

#import "WQPropertyVC.h"
#import "WQMessageVC.h"

#import "WQSelectedProObj.h"

#import "BlockAlertView.h"



@interface WQProductDetailVC ()<WQNavBarViewDelegate,UITableViewDataSource, UITableViewDelegate,ImgScrollViewDelegate,WQProHeaderDelegate,WQPropertyVCDelegate>

@property (nonatomic, strong) UITableView *tableView;
///带图片的数组
@property (nonatomic, strong) NSMutableArray *dataArray;

///点击看大图
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UIView *scrollPanel;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) WQSelectedProObj *selectedPro;


@end


@implementation WQProductDetailVC

-(void)dealloc {
    SafeRelease(_tableView.delegate);
    SafeRelease(_tableView.dataSource);
    SafeRelease(_tableView);
    SafeRelease(_dataArray);
    SafeRelease(_myScrollView);
    SafeRelease(_markView);
    SafeRelease(_scrollPanel);
    SafeRelease(_pageControl);
    SafeRelease(_selectedPro);
}

-(void)leftBtnClickByNavBarView:(WQNavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //导航栏
    [self.navBarView setTitleString:NSLocalizedString(@"ProductDetails", @"")];
    [self.navBarView.rightBtn setHidden:YES];
    self.navBarView.navDelegate = self;
    self.navBarView.isShowShadow = YES;
    [self.view addSubview:self.navBarView];
    
    [self.tableView reloadData];
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
#pragma mark - property

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height} style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[WQProHeader class] forHeaderFooterViewReuseIdentifier:@"WQProHeader"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(UIView *)scrollPanel {
    if (!_scrollPanel) {
        _scrollPanel = [[UIView alloc] initWithFrame:self.view.bounds];
        _scrollPanel.backgroundColor = [UIColor clearColor];
        _scrollPanel.alpha = 0;
        [self.view addSubview:_scrollPanel];
    }
    return _scrollPanel;
}
-(UIView *)markView {
    if (!_markView) {
        _markView = [[UIView alloc] initWithFrame:self.scrollPanel.bounds];
        _markView.backgroundColor = [UIColor blackColor];
        _markView.alpha = 0.0;
        [self.scrollPanel insertSubview:_markView belowSubview:self.myScrollView];
    }
    return _markView;
}
-(UIScrollView *)myScrollView {
    if (!_myScrollView) {
        _myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.scrollPanel addSubview:_myScrollView];
        _myScrollView.pagingEnabled = YES;
        _myScrollView.delegate = self;
    }
    return _myScrollView;
}

-(UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:(CGRect){0,self.view.height-20,self.view.width,20}];
        _pageControl.userInteractionEnabled = NO;
        [self.scrollPanel insertSubview:_pageControl aboveSubview:self.myScrollView];
    }
    return _pageControl;
}
#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return 210;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section==0) {
        WQProHeader *header = (WQProHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"WQProHeader"];
        header.imageString = self.productObj.proImage;
        header.delegate = self;
        return header;
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        CGSize size = [self.productObj.proName boundingRectWithSize:CGSizeMake(self.view.width-20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil] context:nil].size;
        
        if (size.height<20) {
            return 55;
        }else {
            return size.height+35;
        }
    }
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        static NSString * identifier = @"WQProDetailCell";
        WQProDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[WQProDetailCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier ];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell setProductObj:self.productObj];
        return cell;
    }else {
        static NSString * identifier = @"WQProCell";
        WQProCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[WQProCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier ];
        }
        [cell setIdxPath:indexPath];
        
        if (indexPath.section==1) {
            if (self.selectedPro) {
                [cell setSelectedPro:self.selectedPro];
            }
        }
        
        if (indexPath.section==3) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==1) {
        WQPropertyVC *propertyVC = [[WQPropertyVC alloc]init];
        propertyVC.productObj = self.productObj;
        propertyVC.delegate = self;
        propertyVC.proObj = self.selectedPro;
        [self.navigationController pushViewController:propertyVC animated:YES];
        SafeRelease(propertyVC);
    }else if (indexPath.section==2) {
        WQMessageVC *messageVC = [[WQMessageVC alloc]init];
        [self.navigationController pushViewController:messageVC animated:YES];
        SafeRelease(messageVC);
    }else if (indexPath.section==3) {
        if (self.selectedPro) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.interfaceTask = [[WQAPIClient sharedClient] POST:@"/rest/order/addOrder" parameters:@{@"productId":[NSNumber numberWithInteger:self.productObj.proId],@"colorId":[NSNumber numberWithInteger:self.selectedPro.colorId],@"sizeId":[NSNumber numberWithInteger:self.selectedPro.sizeId],@"count":[NSNumber numberWithInteger:self.selectedPro.number]} success:^(NSURLSessionDataTask *task, id responseObject) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *jsonData=(NSDictionary *)responseObject;
                    
                    if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                        
                        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"notice", @"") message:NSLocalizedString(@"OrderSucess", @"")];
                        [alert setDestructiveButtonWithTitle:NSLocalizedString(@"Confirm", @"") block:^{
                            
                        }];
                        [alert show];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }else {
                        [WQPopView showWithImageName:@"picker_alert_sigh" message:[jsonData objectForKey:@"msg"]];
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"InterfaceError", @"")];
            }];
        }else {
            [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"SelectedProperty", @"")];
        }
    }
}

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 150;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

#pragma mark - tableView  header代理--看大图
static NSInteger pageCount = 0;
-(void)imagePressedWithHeader:(WQProHeader *)header imgView:(UIImageView *)imgView atIndex:(NSInteger)index {
    //图片count
    pageCount = header.dataArray.count;
    self.pageControl.numberOfPages = pageCount;
    
    //scrollview的contentSize
    CGSize contentSize = self.myScrollView.contentSize;
    contentSize.height = self.view.height;
    contentSize.width = self.view.width * pageCount;
    self.myScrollView.contentSize = contentSize;
    
    [self.view bringSubviewToFront:self.scrollPanel];
    self.scrollPanel.alpha = 1.0;
    self.currentIndex = index;
    self.pageControl.currentPage = index;
    
    //转换后的rect
    CGRect convertRect = [[imgView superview] convertRect:imgView.frame toView:self.view];
    CGPoint contentOffset = self.myScrollView.contentOffset;
    contentOffset.x = self.currentIndex*self.view.width;
    self.myScrollView.contentOffset = contentOffset;
    //添加
    [self addSubImgViewWithArray:header.dataArray rect:convertRect];
    
    ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){contentOffset,self.myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:imgView.image];
    [self.myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
    tmpImgScrollView = nil;
}

-(void)addSubImgViewWithArray:(NSArray *)array rect:(CGRect)convertRect{
    [self.myScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < pageCount; i ++) {
        if (i == self.currentIndex) {
            continue;
        }
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:(CGRect){0,0,self.view.width,150}];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,array[i]]] placeholderImage:[UIImage imageNamed:@"assets_placeholder_picture"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){i*self.myScrollView.width,0,self.myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:imageView.image];
        [self.myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        [tmpImgScrollView setAnimationRect];
        SafeRelease(tmpImgScrollView);
        SafeRelease(imageView);
    }
}

- (void) setOriginFrame:(ImgScrollView *) sender {
    [UIView animateWithDuration:0.3 animations:^{
        [sender setAnimationRect];
        self.markView.alpha = 1.0;
    }];
}

- (void) tapImageViewTappedWithObject:(id)sender {
    ImgScrollView *tmpImgView = sender;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.markView.alpha = 0;
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished) {
        self.scrollPanel.alpha = 0;
        [self.myScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.width;
    self.currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = self.currentIndex;
}


-(void)selectedProProperty:(WQSelectedProObj *)property {
    self.selectedPro = property;
    
    [self.tableView reloadData];
}
@end
