//
//  WQHotSaleCell.m
//  App
//
//  Created by 邱成西 on 15/3/31.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQHotSaleCell.h"

@interface WQHotSaleCell ()
//图片
@property (nonatomic, strong) UIImageView *proImage;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *saleLab;

@end

@implementation WQHotSaleCell

-(void)dealloc {
    SafeRelease(_proImage);
    SafeRelease(_priceLab);
    SafeRelease(_nameLab);
    SafeRelease(_saleLab);
    SafeRelease(_productObj);
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        
        self.proImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.proImage.backgroundColor = [UIColor clearColor];
        self.proImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.proImage.layer.masksToBounds = YES;
        self.proImage.layer.cornerRadius = 6;
        self.proImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.proImage];
        
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.backgroundColor = [UIColor clearColor];
        self.priceLab.textColor = COLOR(251, 0, 41, 1);
        self.priceLab.font = [UIFont systemFontOfSize:15];
//        self.priceLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.priceLab];
        
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.nameLab.backgroundColor = [UIColor clearColor];
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.nameLab];
        
        self.saleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.saleLab.backgroundColor = [UIColor clearColor];
        self.saleLab.font = [UIFont systemFontOfSize:12];
        self.saleLab.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.saleLab];
    }
    
    return self;
}



-(void)setProductObj:(WQProductObj *)productObj {
    _productObj = productObj;
    
    NSArray *imgArray = [productObj.proImage componentsSeparatedByString:@"|"];
    
    [self.proImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"assets_placeholder_picture"]];
    
    //￥ ＄ €
    self.priceLab.text = [NSString stringWithFormat:@"%@ %@",[Utility returnMoneyWithType:productObj.moneyType],productObj.proPrice];
    
    self.nameLab.text = productObj.proName;

    self.saleLab.text = [NSString stringWithFormat:@"%@:%d",NSLocalizedString(@"HasSale", @""),productObj.proSaleCount];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    //(60,60)
    self.proImage.frame = (CGRect){(self.contentView.width-60)/2,10,60,60};
    
    self.priceLab.frame = (CGRect){5,self.proImage.bottom+5,self.contentView.width-10,15};
    
    self.nameLab.frame = (CGRect){5,self.priceLab.bottom+5,self.contentView.width-10,15};
    
    self.saleLab.frame = (CGRect){5,self.nameLab.bottom+5,self.contentView.width-10,12};
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.priceLab.text = nil;
    self.proImage.layer.borderWidth = 0;
    self.proImage.image = nil;
    self.nameLab.text = nil;
    self.saleLab.text = nil;
    self.productObj = nil;
}
@end
