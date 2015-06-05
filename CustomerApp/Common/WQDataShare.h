//
//  WQDataShare.h
//  App
//
//  Created by 邱成西 on 15/2/2.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WQUserObj.h"
#import "WQStoreObj.h"

@interface WQDataShare : NSObject

//区分6、7statusBar高度
@property (nonatomic, assign) NSInteger statusHeight;

@property (nonatomic, strong) WQUserObj *userObj;
@property (nonatomic, strong) WQStoreObj *storeObj;

///xmpp注册
@property (nonatomic, assign) BOOL idRegister;//1＝注册，0=未注册

@property (nonatomic, assign) BOOL isInMessageView;
///当前聊天对象的JID
@property (nonatomic, strong) NSString *otherJID;

///聊天输入框获取键盘语言
@property (nonatomic, strong) NSString *getLanguage;

@property (nonatomic, strong) NSMutableArray *messageArray;

+ (WQDataShare *)sharedService;


///红点
@property (nonatomic, assign) BOOL myselfPoint;//第4个item  我
@end
