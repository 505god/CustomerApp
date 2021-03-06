//
//  WQCustomerOrderObj.h
//  App
//
//  Created by 邱成西 on 15/4/15.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WQCustomerOrderObj : NSObject

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderTime;
///订单价格
@property (nonatomic, assign) CGFloat orderPrice;
///订单状态
@property (nonatomic, assign) NSInteger orderStatus;


@property (nonatomic, assign) NSInteger customerId;
@property (nonatomic, strong) NSString *customerName;

@property (nonatomic, assign) NSInteger productId;
@property (nonatomic, strong) NSString *productImg;
@property (nonatomic, strong) NSString *productColor;
@property (nonatomic, strong) NSString *productSize;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) CGFloat productPrice;
@property (nonatomic, assign) NSInteger productNumber;

@property (nonatomic, assign) NSInteger productMoneyType;
///产品优惠  0=无  1=折扣  2＝优惠价格
@property (nonatomic, assign) NSInteger productSaleType;
@property (nonatomic, assign) CGFloat productDiscount;
@property (nonatomic, assign) CGFloat productReducePrice;


//订单被提醒付款
@property (nonatomic, assign) NSInteger remindPayRedPoint;
//订单已发货
@property (nonatomic, assign) NSInteger deliveryRedPoint;
//订单被提醒发货
@property (nonatomic, assign) NSInteger remindDeliveryRedPoint;
//订单已完成
@property (nonatomic, assign) NSInteger finishRedPoint;
@end
