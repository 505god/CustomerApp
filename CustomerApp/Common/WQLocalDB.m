//
//  WQLocalDB.m
//  App
//
//  Created by 邱成西 on 15/4/22.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQLocalDB.h"

@interface WQLocalDB (DBPrivate)
-(WQUserObj *)userModelFromLocal:(FMResultSet *)rs;
-(WQStoreObj *)storeModelFromLocal:(FMResultSet *)rs;
-(WQMessageObj *)messageModelFromLocal:(FMResultSet *)rs;
@end

@implementation WQLocalDB (DBPrivate)
-(WQUserObj *)userModelFromLocal:(FMResultSet *)rs {
    WQUserObj *userObj = [[WQUserObj alloc]init];
    userObj.userId = [[rs stringForColumn:@"userId"] integerValue];
    userObj.userHead = [rs stringForColumn:@"userHead"];
    userObj.userName = [rs stringForColumn:@"userName"];
    userObj.userPhone = [rs stringForColumn:@"userPhone"];
    return userObj;
}
-(WQStoreObj *)storeModelFromLocal:(FMResultSet *)rs {
    WQStoreObj *storeObj = [[WQStoreObj alloc]init];
    storeObj.storeId = [[rs stringForColumn:@"storeId"] integerValue];
    storeObj.storeName = [rs stringForColumn:@"storeName"];
    storeObj.storeHead = [rs stringForColumn:@"storeHead"];
    
    return storeObj;
}
-(WQMessageObj *)messageModelFromLocal:(FMResultSet *)rs {
    WQMessageObj *messageObj = [[WQMessageObj alloc]init];
    messageObj.messageFrom = [[rs stringForColumn:@"messageFrom"] integerValue];
    messageObj.messageTo = [[rs stringForColumn:@"messageTo"] integerValue];
    messageObj.messageContent = [rs stringForColumn:@"messageContent"];
    messageObj.messageDate = [rs stringForColumn:@"messageDate"];
    messageObj.messageType = [[rs stringForColumn:@"messageType"]integerValue];
    
    if (messageObj.messageFrom == [WQDataShare sharedService].userObj.userId) {
        messageObj.fromType = WQMessageFromMe;
    }else {
        messageObj.fromType = WQMessageFromOther;
    }
    return messageObj;
}
@end

@implementation WQLocalDB

+(WQLocalDB *)sharedWQLocalDB {
    static WQLocalDB *sharedRPLocalDB=nil;
    
    @synchronized(self)
    {
        if (!sharedRPLocalDB)
            sharedRPLocalDB = [[WQLocalDB alloc] init];
        
        return sharedRPLocalDB;
    }
}

#pragma mark - 用户

-(void)saveUserDataToLocal:(WQUserObj *)user completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];

    [self.db executeUpdate:@"delete from WQUser"];

    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:4];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",user.userId]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.userName]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.userHead]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",user.userPhone]];
    
    BOOL res = [self.db executeUpdate:@"insert into WQUser (userId,userName,userHead,userPhone) values (?,?,?,?)" withArgumentsInArray:argumentsArray];

    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}
-(void)getLocalUserDataWithCompleteBlock:(void (^)(NSArray *array))compleBlock {
    [self.db open];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    FMResultSet * rs = [self.db executeQuery:@"select * from WQUser"];
    
    while ([rs next]) {
        WQUserObj *tempUser = [self userModelFromLocal:rs];
        [mutableArray addObject:tempUser];
        tempUser = nil;
    }
    
    [rs close];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(mutableArray);
    }
}
-(void)deleteLocalUserWithCompleteBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    BOOL res = [self.db executeUpdate:@"delete from WQUser"];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}


#pragma mark - 店铺
-(void)saveStroeDataToLocal:(WQStoreObj *)store completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    [self.db executeUpdate:@"delete from WQStore"];
    
    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:4];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",store.storeId]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",store.storeName]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",store.storeHead]];
    
    BOOL res = [self.db executeUpdate:@"insert into WQStore (storeId,storeName,storeHead) values (?,?,?)" withArgumentsInArray:argumentsArray];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}
-(void)getLocalStroeDataWithCompleteBlock:(void (^)(NSArray *array))compleBlock {
    [self.db open];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    FMResultSet * rs = [self.db executeQuery:@"select * from WQStore"];
    
    while ([rs next]) {
        WQStoreObj *tempUser = [self storeModelFromLocal:rs];
        [mutableArray addObject:tempUser];
        tempUser = nil;
    }
    
    [rs close];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(mutableArray);
    }
}
-(void)deleteLocalStroeWithCompleteBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    BOOL res = [self.db executeUpdate:@"delete from WQStore"];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}
#pragma mark - 消息
-(void)saveMessageToLocal:(WQMessageObj *)messageObj completeBlock:(void (^)(BOOL finished))compleBlock {
    [self.db open];
    
    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:5];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",messageObj.messageFrom]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",messageObj.messageTo]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",messageObj.messageContent]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%@",messageObj.messageDate]];
    [argumentsArray addObject:[NSString stringWithFormat:@"%d",messageObj.messageType]];
    
    BOOL res = [self.db executeUpdate:@"insert into WQMessage (messageFrom,messageTo,messageContent,messageDate,messageType) values (?,?,?,?,?)" withArgumentsInArray:argumentsArray];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(res);
    }
}

-(void)getLocalMessageWithId:(NSString *)id1 Id:(NSString *)id2 start:(NSString *)start completeBlock:(void (^)(NSArray *array))compleBlock {
    
    if(id1==nil || id2==nil){
        return;
    }
    
    [self.db open];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    FMResultSet * rs = [self.db executeQuery:@"select * from WQMessage where (messageFrom=? and messageTo=?)|(messageFrom=? and messageTo=?) order by id desc limit ?,10",id1,id2,id2,id1,start];
    
    while ([rs next]) {
        WQMessageObj *message = [self messageModelFromLocal:rs];
        [mutableArray addObject:message];
        message = nil;
    }
    
    [rs close];
    [self.db close];
    
    if (compleBlock) {
        compleBlock(mutableArray);
    }
}
-(void)getLatestMessageWithId:(NSString *)id1 Id:(NSString *)id2 completeBlock:(void (^)(WQMessageObj *messageObj))compleBlock {
    if(id1==nil || id2==nil){
        return;
    }
    
    [self.db open];
    
    FMResultSet * rs = [self.db executeQuery:@"select * from WQMessage where (messageFrom=? and messageTo=?)|(messageFrom=? and messageTo=?) order by id desc limit 0,1",id1,id2,id2,id1];
    
    WQMessageObj *messageObj;
    while ([rs next]) {
        messageObj = [self messageModelFromLocal:rs];
    }
    [rs close];
    
    [self.db close];
    
    if (compleBlock) {
        compleBlock(messageObj);
    }
}
@end
