//
//  WQProDetailCell.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/17.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQProDetailCell.h"

@interface WQProDetailCell ()

@property (nonatomic, strong) UILabel *detailLab;

@property (nonatomic, strong) UILabel *priceLab;

@property (nonatomic, strong) UILabel *saleLab;
@end

@implementation WQProDetailCell

-(void)dealloc {
    SafeRelease(_detailLab);
    SafeRelease(_productObj);
    SafeRelease(_priceLab);
    SafeRelease(_saleLab);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.detailLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.detailLab.font = [UIFont systemFontOfSize:16];
        self.detailLab.backgroundColor = [UIColor clearColor];
        self.detailLab.numberOfLines = 0;
        self.detailLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.detailLab];
        
        self.priceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.priceLab.font = [UIFont systemFontOfSize:16];
        self.priceLab.textColor = COLOR(251, 0, 41, 1);
        self.priceLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.priceLab];
        
        self.saleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.saleLab.font = [UIFont systemFontOfSize:14];
        self.saleLab.textColor = [UIColor lightGrayColor];
        self.saleLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.saleLab];
        
        
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setProductObj:(WQProductObj *)productObj {
    _productObj = productObj;
    
    self.detailLab.text = productObj.proName;
    self.priceLab.text = [NSString stringWithFormat:@"%@ %@",[Utility returnMoneyWithType:productObj.moneyType],productObj.proPrice];
    
    if (productObj.proOnSaleType==0) {//无优惠
        self.saleLab.text = @"";
        [self.saleLab setHidden:YES];
    }else if (productObj.proOnSaleType==1) {//价格优惠
        [self.saleLab setHidden:NO];
        self.saleLab.text = [NSString stringWithFormat:NSLocalizedString(@"orderSale", @""),[productObj.onSalePrice floatValue]];
    }else if (productObj.proOnSaleType==2) {//折扣优惠
        [self.saleLab setHidden:NO];
        
        self.saleLab.text = [NSString stringWithFormat:@"%d%@",(NSInteger)([productObj.onSalePrice floatValue]),NSLocalizedString(@"proDiscount", @"")];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = (CGRect){0,0,self.width,self.height};
    
    CGSize size = [self.detailLab.text boundingRectWithSize:CGSizeMake(self.width-20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil] context:nil].size;
    self.detailLab.frame = (CGRect){10,5,size.width,size.height};
    
    [self.priceLab sizeToFit];
    self.priceLab.frame = (CGRect){10,self.detailLab.bottom+5,self.priceLab.width,self.priceLab.height};
    
    [self.saleLab sizeToFit];
    self.saleLab.frame = (CGRect){self.priceLab.right+30,self.detailLab.bottom+5,self.saleLab.width,self.saleLab.height};
}
-(void)prepareForReuse {
    [super prepareForReuse];
    self.detailLab.text = nil;
    self.priceLab.text = nil;
    self.saleLab.text = nil;
}
@end
