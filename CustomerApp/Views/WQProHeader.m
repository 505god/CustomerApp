//
//  WQProHeader.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/14.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQProHeader.h"
#import "XLCycleScrollView.h"

@interface WQProHeader ()<XLCycleScrollViewDelegate,XLCycleScrollViewDatasource>

@property (nonatomic, strong) XLCycleScrollView *scrollView;


@end

@implementation WQProHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setImageString:(NSString *)imageString {
    _imageString = imageString;
    
     NSArray *imgArray = [imageString componentsSeparatedByString:@"|"];
    self.dataArray = imgArray;
    
    self.scrollView = [[XLCycleScrollView alloc]initWithFrame:(CGRect){0,0,[UIScreen mainScreen].bounds.size.width,200}];
    self.scrollView.delegate = self;
    self.scrollView.datasource = self;
    [self.contentView addSubview:self.scrollView];
    
    [self.scrollView reloadData];
}

#pragma mark - XLCycleScrollView代理
- (NSInteger)numberOfPages {
    return self.dataArray.count;
}
- (UIView *)pageAtIndex:(NSInteger)index {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:(CGRect){0,0,self.scrollView.width,self.scrollView.height}];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,self.dataArray[index]]] placeholderImage:[UIImage imageNamed:@"assets_placeholder_picture"]];
    return imageView;
}
- (void)didClickPage:(XLCycleScrollView *)csView view:(UIView *)view atIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePressedWithHeader:imgView:atIndex:)]) {
        [self.delegate imagePressedWithHeader:self imgView:(UIImageView *)view atIndex:index];
    }
}
@end
