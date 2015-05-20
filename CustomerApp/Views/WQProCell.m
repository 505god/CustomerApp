//
//  WQProCell.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/16.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQProCell.h"
#import "WQCellSelectedBackground.h"

@interface WQProCell ()

@end

@implementation WQProCell

-(void)dealloc {
    SafeRelease(_idxPath);
    SafeRelease(_selectedPro);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        WQCellSelectedBackground *selectedBackgroundView = [[WQCellSelectedBackground alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedBackgroundView];
        
        NSMutableArray *colors = [NSMutableArray array];
        [colors addObject:(id)[[UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1] CGColor]];
        [self setSelectedBackgroundViewGradientColors:colors];
        
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelectedBackgroundViewGradientColors:(NSArray*)colors {
    [(WQCellSelectedBackground*)self.selectedBackgroundView setSelectedBackgroundGradientColors:colors];
}

-(void)setIdxPath:(NSIndexPath *)idxPath {
    _idxPath = idxPath;
    
    if (self.idxPath.section==1) {
        self.textLabel.text = NSLocalizedString(@"SelectedProperty", @"");
        self.detailTextLabel.text = @"";
    }else if (self.idxPath.section==2) {
        self.textLabel.text = NSLocalizedString(@"ContactSeller", @"");
    }else if (self.idxPath.section==3) {
        self.textLabel.text = NSLocalizedString(@"BuyNow", @"");
        self.detailTextLabel.text = @"";
    }
}

-(void)setSelectedPro:(WQSelectedProObj *)selectedPro {
    _selectedPro = selectedPro;
    
    if (self.idxPath.section == 1) {
        self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"confirmSelectedPro", @""),selectedPro.colorName,selectedPro.sizeName,selectedPro.number];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = (CGRect){0,0,self.width,self.height};
    
    [self.textLabel sizeToFit];
    if (self.idxPath.section==3) {
        self.textLabel.frame = (CGRect){(self.width-self.textLabel.width)/2,(self.height-self.textLabel.height)/2,self.textLabel.width,self.textLabel.height};
    }else {
        self.textLabel.frame = (CGRect){10,(self.height-self.textLabel.height)/2,self.textLabel.width,self.textLabel.height};
    }
    
    
    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.frame = (CGRect){self.textLabel.right+5,(self.contentView.height-self.detailTextLabel.height)/2,self.contentView.width-self.textLabel.right-32,self.detailTextLabel.height};
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}
@end
