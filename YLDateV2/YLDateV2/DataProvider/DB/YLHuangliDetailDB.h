//
//  YLHuangliDetailDB.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/4.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDBManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 黄历数据库
 bundle 中的 HuangliDetails.db
 --by zwh
 */
@interface YLHuangliDetailDB : YLDBManager

/**
 通过值神的名字获取值神的详细说明

 @param name 值神名字
 */
+ (NSArray<NSString *> *)queryZhishenDetailByName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
