//
//  YLDateUnit.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/22.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 农历单位数据
 例如；
 农历月：idx = 1，name = "正月"
 农历日：idx = 3，name = "初三"
 天干： idx = 0，name = "甲"
 生肖： idx = 0，name = "鼠"
 同时，会以 name 作为对象的 description
 @warning 不要直接使用
 --by zwh
 */
@interface YLDateUnit : NSString

/** 对应单位的数值 */
@property (nonatomic, readonly) NSInteger idx;

/** 初始化方法 */
+ (instancetype)unitWith:(NSString *)name
                     idx:(NSInteger)idx;

@end

/** 已知天干下标和地支下标，计算干支下标 */
FOUNDATION_EXTERN NSInteger ylStemBranchIndexOf(NSInteger stem, NSInteger branch);

/** 天干地支 */
@interface YLStemBranch : NSObject

/** 天干 */
@property (nonatomic, strong, readonly) YLDateUnit *stem;
/** 地支 */
@property (nonatomic, strong, readonly) YLDateUnit *branch;

/** 初始化方法 */
+ (instancetype)stem:(YLDateUnit *)stem
              branch:(YLDateUnit *)branch;

@end

/** 节气时间 */
@interface YLTermTime : NSObject

/** 时 */
@property (nonatomic, readonly) NSInteger hour;
/** 分 */
@property (nonatomic, readonly) NSInteger minute;
/** 秒 */
@property (nonatomic, readonly) NSInteger second;

/** 初始化方法 */
+ (instancetype)termTimeWith:(NSInteger)hour
                      minute:(NSInteger)minute
                      second:(NSInteger)second;

@end

/** 宜忌 */
@interface YLYiJi : NSObject

/** 宜 */
@property (nonatomic, strong, readonly) NSString *yi;
/** 忌 */
@property (nonatomic, strong, readonly) NSString *ji;

/** 初始化方法 */
+ (instancetype)yi:(NSString *)yi
                ji:(NSString *)ji;

@end

NS_ASSUME_NONNULL_END
