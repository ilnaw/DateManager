//
//  YLDBManager.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/12.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 数据库基类
 --by zwh
 */
@interface YLDBManager : NSObject

/** 数据库文件路径(子类重写) */
@property (class, nonatomic, strong, readonly) NSString *dbPath;
/** 数据库类(应为FMDatabase的子类)。默认为 FMDatabase */
@property (class, nonatomic, readonly) Class databaseClass;

/** 连接数据库的串行读写队列，子类重写 */
@property (class, nonatomic, readonly) dispatch_queue_t dbQueue;

/**
 异步连接数据库

 @param action 数据库操作
 @param done 处理完成回调
 */
+ (void)asyncConnectTo:(void (^_Nullable)(FMDatabase *db))action
                  done:(void (^_Nullable)(void))done;

/**
 同步连接数据库

 @param action 数据库操作
 */
+ (void)syncConnectTo:(void (^)(FMDatabase *db))action;

@end

NS_ASSUME_NONNULL_END
