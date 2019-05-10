//
//  YLSAADB.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/8.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDBManager.h"
#import "YLSAAModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 老黄历数据库，多为宜忌、解释
 --by zwh
 */
@interface YLSAADB : YLDBManager

+ (YLSAAIndexEntity *)queryIndexTableEntity:(NSString *)_Date;

/**
 查询数据库中的 explain 表

 @param ancient 古文
 @return 现代文解释
 */
+ (NSString *)explain:(NSString *)ancient;

/**
 查询数据库中的 YJData 表

 @param jx 吉凶下标
 @param gz 干支下标
 */
+ (YLYJDataEntity *)queryYJData:(NSInteger)jx
                             gz:(NSInteger)gz;

@end

NS_ASSUME_NONNULL_END
