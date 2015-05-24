//
//  WQTabBarView.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/12.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQTabBarView.h"

@implementation WQTabBarView

-(void)dealloc {
    SafeRelease(_hotItem);
    SafeRelease(_classItem);
    SafeRelease(_orderItem);
    SafeRelease(_myselfItem);
    SafeRelease(_searchItem);
    SafeRelease(_delegate);
}
-(void)defaultSelected{
    [self unSelectedAllItems];
}

-(void)unSelectedAllItems{
    self.hotItem.isSelected = NO;
    self.classItem.isSelected = NO;
    self.orderItem.isSelected = NO;
    self.myselfItem.isSelected = NO;
    self.searchItem.isSelected = NO;
}

-(void)whiteViewSelected {
    [self.hotItem.whiteView setHidden:NO];
    [self.classItem.whiteView setHidden:NO];
    [self.orderItem.whiteView setHidden:NO];
    [self.searchItem.whiteView setHidden:NO];
}

- (IBAction)hotItemClicked:(id)sender {
    [self unSelectedAllItems];
    [self whiteViewSelected];
    self.hotItem.isSelected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectedItem:)]) {
        [self.delegate tabBar:self selectedItem:TabBarItemType_hot];
    }
}
- (IBAction)classItemClicked:(id)sender {
    [self unSelectedAllItems];
    [self whiteViewSelected];
    self.classItem.isSelected = YES;
    [self.hotItem.whiteView setHidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectedItem:)]) {
        [self.delegate tabBar:self selectedItem:TabBarItemType_class];
    }
}
- (IBAction)searchItemClicked:(id)sender {
    [self unSelectedAllItems];
    [self whiteViewSelected];
    self.searchItem.isSelected = YES;
    [self.classItem.whiteView setHidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectedItem:)]) {
        [self.delegate tabBar:self selectedItem:TabBarItemType_search];
    }
}
- (IBAction)chatItemClicked:(id)sender {
    [self unSelectedAllItems];
    [self whiteViewSelected];
    self.orderItem.isSelected = YES;
    [self.searchItem.whiteView setHidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectedItem:)]) {
        [self.delegate tabBar:self selectedItem:TabBarItemType_chat];
    }
}
- (IBAction)myselfItemClicked:(id)sender {
    [self unSelectedAllItems];
    [self whiteViewSelected];
    self.myselfItem.isSelected = YES;
    [self.orderItem.whiteView setHidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectedItem:)]) {
        [self.delegate tabBar:self selectedItem:TabBarItemType_myself];
    }
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = (CGRect){0,[UIScreen mainScreen].bounds.size.height-NavgationHeight,[UIScreen mainScreen].bounds.size.width,NavgationHeight};
    
//    self.hotItem.frame = (CGRect){0,0,self.width/4,NavgationHeight};
//    self.classItem.frame = (CGRect){self.hotItem.right,0,self.width/4,NavgationHeight};
//    self.orderItem.frame = (CGRect){self.classItem.right,0,self.width/4,NavgationHeight};
//    self.myselfItem.frame = (CGRect){self.orderItem.right,0,self.width/4,NavgationHeight};
}

-(void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    
    [self defaultSelected];
    
    switch (currentPage) {
        case 0:
            self.hotItem.isSelected = YES;
            break;
        case 1:
            self.classItem.isSelected = YES;
            break;
        case 2:
            self.searchItem.isSelected = YES;
            break;
        case 3:
            self.orderItem.isSelected = YES;
            break;
        case 4:
            self.myselfItem.isSelected = YES;
            break;
            
        default:
            break;
    }
}
@end
