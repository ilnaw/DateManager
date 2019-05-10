//
//  YLDBEntity.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/4.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 数据库实体基类
 --by zwh
 */
@interface YLDBEntity : NSObject

/**
 通过数据库查询结构构造实体

 @param set 数据库查询结果
 */
+ (instancetype)entityByResult:(FMResultSet *)set;

@end

NS_ASSUME_NONNULL_END
