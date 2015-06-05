//
//  WQMainRightCell.m
//  App
//
//  Created by 邱成西 on 15/4/3.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQMainRightCell.h"
#import "WQCellSelectedBackground.h"
#import "RKNotificationHub.h"
@interface WQMainRightCell ()
@property (nonatomic, strong) RKNotificationHub *notificationHub;

@end

@implementation WQMainRightCell

-(void)dealloc {
    SafeRelease(_headerImageView);
    SafeRelease(_titleLab);
    SafeRelease(_detailLab);
    SafeRelease(_lineView);
    SafeRelease(_notificationHub);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.accessoryView.backgroundColor = [UIColor redColor];
        
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.titleLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLab];
        
        self.detailLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.detailLab.backgroundColor = [UIColor clearColor];
        self.detailLab.font = [UIFont systemFontOfSize:15];
        self.detailLab.textColor = [UIColor lightGrayColor];
        self.detailLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.detailLab];
        
        self.lineView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineView.image = [UIImage imageNamed:@"line"];
        [self.contentView addSubview:self.lineView];
        
        self.headerImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.headerImageView.image = [UIImage imageNamed:@"assets_placeholder_picture"];
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerImageView.layer.cornerRadius = 6;
        self.headerImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headerImageView];
        
        WQCellSelectedBackground *selectedBackgroundView = [[WQCellSelectedBackground alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedBackgroundView];
        
        NSMutableArray *colors = [NSMutableArray array];
        [colors addObject:(id)[[UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1] CGColor]];
        [self setSelectedBackgroundViewGradientColors:colors];
        
        self.notificationHub = [[RKNotificationHub alloc]initWithView:self];
        [self.notificationHub setCount:-1];
    }
    return self;
}

- (void)setSelectedBackgroundViewGradientColors:(NSArray*)colors {
    [(WQCellSelectedBackground*)self.selectedBackgroundView setSelectedBackgroundGradientColors:colors];
}

-(void)setHeaderImageViewImage:(NSString *)header {
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:header] placeholderImage:[UIImage imageNamed:@"assets_placeholder_picture"]];
}

//头像固定为60x60
-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = (CGRect){0,0,self.width,self.height};
    
    [self.titleLab sizeToFit];
    self.titleLab.frame = (CGRect){10,(self.contentView.height-20)/2,self.titleLab.width,20};
    
    self.detailLab.frame = (CGRect){self.titleLab.right,self.titleLab.top,self.contentView.width-self.titleLab.right-32,20};
    
    self.lineView.frame = (CGRect){10,self.height-1,self.width-10,2};
    
    self.headerImageView.frame = (CGRect){self.contentView.width-32-60,5,60,60};
    
    self.textLabel.frame = (CGRect){0,0,self.contentView.width,self.contentView.height};
    
    [self.notificationHub setCircleAtFrame:(CGRect){self.titleLab.right,self.titleLab.top-5,10,10}];
}

-(void)setIsRedPoint:(BOOL)isRedPoint {
    _isRedPoint = isRedPoint;
    
    if (isRedPoint) {
        [self.notificationHub setCount:0];
        [self.notificationHub bump];
    }else {
        [self.notificationHub setCount:-1];
    }
}

@end
