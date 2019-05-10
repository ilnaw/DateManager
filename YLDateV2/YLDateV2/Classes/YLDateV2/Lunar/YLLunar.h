//
//  YLLunar.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "_YLDate.h"
#import "YLDateUnit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 农历类
 农历年份支持 1900～2135
 @warning 不要直接使用
 --by zwh
 */
@interface YLLunar : _YLDate

/** 农历月份(正月、二月...共12个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *months;
/** 农历日(初一、初二...共30个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *days;
/** 生肖(鼠、牛...共12个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *animals;

/** 检查日期是否支持农历(农历数据仅支持1900～2135年, 超过这个范围的数据暂不支持) */
+ (BOOL)isLunarValid:(NSDate *)date;
@property (nonatomic, readonly, getter=isValid) BOOL valid;

#pragma mark - 这一天的农历属性
/**
 新历年
 @warning
 注意: 如果日期未到今年春节，则年份为上一年, 例如:
 1902.2.7(农历腊月廿九), 则 year = 1901
 1902.2.8(农历正月初一), 则 year = 1902
 */
@property (nonatomic, readonly) NSInteger year;
/** 月 @warning idx = 1 name = 正月 */
@property (nonatomic, strong, readonly) YLDateUnit *month;
/** 是否是闰月 */
@property (nonatomic, readonly) BOOL isLeapMonth;
/** 日 @warning idx = 1 name = 初一 */
@property (nonatomic, strong, readonly) YLDateUnit *day;
/** 生肖 @warning idx = 0 name = 鼠 */
@property (nonatomic, strong, readonly) YLDateUnit *animal;

/** 当前月的天数 @warning 农历月仅分大小月，大月30，小月29 */
@property (nonatomic, readonly) NSInteger maxDayCountsOfThisMonth;

/**
 通过年月日构造 NSDate

 @param y 新历年
 @param isLeap 是否是闰月
 @param M 农历月份 1 表示 正月
 @param d 农历日  1 表示 初一
 @param H 新历时
 @param m 新历分
 @param s 新历秒
 @return 如果日期无效，返回 nil
 */
+ (NSDate * _Nullable)dateWithYear:(NSInteger)y
                       isLeapMonth:(BOOL)isLeap
                             month:(NSInteger)M
                               day:(NSInteger)d
                              hour:(NSInteger)H
                            minute:(NSInteger)m
                            second:(NSInteger)s;

@end

NS_ASSUME_NONNULL_END
