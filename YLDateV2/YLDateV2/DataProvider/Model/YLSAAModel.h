//
//  YLSAAModel.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/8.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDBEntity.h"

NS_ASSUME_NONNULL_BEGIN

/**
 saa.db 数据库 IndexTable 表对应的实体
 --by zwh
 */
@interface YLSAAIndexEntity : YLDBEntity

/** 日期，目前数据库中的时间范围为2010-01-01～2049-12-31，共计 14610 条数据 */
@property (nonatomic, strong, readonly) NSString *_Date;
/** 吉凶下标，用于在 YJData 中进行查询 */
@property (nonatomic, readonly) NSInteger jx;
/** 干支下标，用于在 YJData 中进行查询 */
@property (nonatomic, readonly) NSInteger gz;

@end

/**
 saa.db 数据库 YJData 表对应的实体
 --by zwh
 */
@interface YLYJDataEntity : YLDBEntity

/** 吉凶下标，用于查询 */
@property (nonatomic, readonly) NSInteger jx;
/** 干支下标，用于查询 */
@property (nonatomic, readonly) NSInteger gz;
/** 忌 */
@property (nonatomic, strong, readonly) NSString *ji;
/** 宜 */
@property (nonatomic, strong, readonly) NSString *yi;

@end

NS_ASSUME_NONNULL_END
