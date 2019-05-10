//
//  YLSolar.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_YLDate.h"
#import "YLDateUnit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 新历类
 @warning 不要直接使用
 --by zwh
 */
@interface YLSolar : _YLDate

/** 星座字符串(白羊座，金牛座) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *constellations;
/** 星座日期范围(03.21~04.12, 04.20~05.20) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *constellationDateRanges;

/** 今年是否是闰年 */
@property (nonatomic, readonly, getter=isLeapYear) BOOL leapYear;

/** 年 */
@property (nonatomic, readonly) NSInteger year;
/** 月 */
@property (nonatomic, readonly) NSInteger month;
/** 日 */
@property (nonatomic, readonly) NSInteger day;
/** 时 */
@property (nonatomic, readonly) NSInteger hour;
/** 分 */
@property (nonatomic, readonly) NSInteger minute;
/** 秒 */
@property (nonatomic, readonly) NSInteger second;
/** 周几 0 = 周日, 1 = 周一, ... 6 = 周六 */
@property (nonatomic, readonly) NSInteger weekday;
/**
 指明当前日期为当月的第几个周几。
 例如：weekday = 1，weekdayOrdinal = 3, 表示当前日期为当月的第三个周一。
 可用于判断类似于母亲节、父亲节等日期。
 区别于 weekOfMonth: 表示当前日期为当月的第几周
 */
@property (nonatomic, readonly) NSInteger weekdayOrdinal;
/** 今年的第几周 */
@property (nonatomic, readonly) NSInteger weekOfYear;

/** 获取当前月的天数 */
@property (nonatomic, readonly) NSInteger maxDayCountsOfThisMonth;
/** 获取当年的天数 */
@property (nonatomic, readonly) NSInteger maxDayCountsOfThisYear;

/** 星座, idx = 0 name = 白羊座 */
@property (nonatomic, strong, readonly) YLDateUnit *constellation;

#pragma mark - Tools
/** 判断是否为闰年 */
+ (BOOL)isLeapYear:(NSInteger)year;
+ (NSInteger)maxDayOf:(NSInteger)year
                month:(NSInteger)month;
@end

NS_ASSUME_NONNULL_END
