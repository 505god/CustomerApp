//
//  WQProCell.h
//  CustomerApp
//
//  Created by 邱成西 on 15/5/16.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WQProductObj.h"
#import "WQSelectedProObj.h"

@interface WQProCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *idxPath;

@property (nonatomic, strong) WQSelectedProObj *selectedPro;

@end
