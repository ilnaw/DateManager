//
//  YLDateV2.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_YLDate.h"
#import "YLSolar.h"
#import "YLLunar.h"
#import "YLAlmanac.h"

NS_ASSUME_NONNULL_BEGIN

// TODO: ... 由于原日期类包含: YLDate、ExtDateTime、ExtDayInfo、Lunar 等(以下统一称为原类)，在使用过程中感觉不是很方便，且可能存在错用的情况。
// 现计划将以上各类的功能进行整合，并提供简单易用的接口以及文档
// 目标：
// 1. 提供原类提供的所有功能。
// 2. 整合以上各类的功能，以分类实现内容的读取。
// 3. 简单易用的接口。
// 初步计划的结构图：
//                          YLDateV2            (初始化以新历为主，农历部分的信息均由新历进行计算和转换获得。大部分属性为只读属性，即初始化时便可以确定)
//                         /        \
//                     YLSolar -> YLLunar --> 提供 year、month、day 等基本内容
//                       /            \
//                生肖、星座 等       天干地支、九星飞宫 等
//
// 目前这个类不会在项目中使用，待功能完成，且单元测试通过后，会逐步将项目中的类以及使用方式进行替换。
// 同时，原类替换完成后，会将本类更名为更适合它的类名 YLDate；删除原类，以及这一段注释

@class YLDateComponents;

/**
 日期类
 封装/整合新历、农历以及其它信息
 --by zwh
 */
@interface YLDateV2 : _YLDate

/** 使用年月日时分秒初始化 */
+ (instancetype _Nullable)dateWithYear:(NSInteger)y
                                 month:(NSInteger)M
                                   day:(NSInteger)d
                                  hour:(NSInteger)H
                                minute:(NSInteger)m
                                second:(NSInteger)s;
/** 使用 NSDateComponents 初始化 */
+ (instancetype _Nullable)dateFromComponents:(NSDateComponents *)components;

/** 根据GMT标准时间与系统本地时区的时差，计算本地系统日期 */
+ (instancetype _Nullable)localeDateFromGMT:(YLDateV2 *)GMTDate;

/**
 根据格式化日期字符串初始化

 @param date 格式化日期字符串
 @param format 格式(例如 yyyy-MM-dd 等)
 */
+ (instancetype _Nullable)dateFromString:(NSString *)date
                                  format:(NSString *)format;

/**
 通过 YLDateComponents 初始化 (支持农历)

 @param components 日期组件 @see YLDateComponents
 @return 如果日期不合法，返回nil
 */
+ (instancetype _Nullable)dateFromDateComponents:(YLDateComponents *)components;

/** 新历 */
@property (nonatomic, strong, readonly) YLSolar *solar;
/** 农历(如果日期不支持，则农历返回nil) @see YLLunar */
@property (nonatomic, strong, readonly, nullable) YLLunar *lunar;
/** 黄历(如果日期不支持，则黄历返回nil，同农历) @see YLLunar */
@property (nonatomic, strong, readonly, nullable) YLAlmanac *almanac;

#pragma mark - 日期操作

/**
 日期偏移

 @param days 偏移的天数。如果为正，返回x天后的日期，为负，返回x天前的日期。
 @return 偏移后的日期
 */
- (YLDateV2 *)daysOffset:(NSInteger)days;

/**
 月份偏移

 @param months 偏移的月份。如果偏移后的日不足，则偏移为该月份的最后一天。例如1.31，偏移一个月后，为2.28/2.29
 @return 偏移后的日期
 */
- (YLDateV2 *)monthsOffset:(NSInteger)months;

/** 是否是同一天 */
- (BOOL)isTheSameDay:(YLDateV2 *)date;

/** 是否是周末 */
@property (nonatomic, readonly) BOOL isWeekend;
/** 是否是今天 */
@property (nonatomic, readonly) BOOL isToday;
/** 是否是明天 */
@property (nonatomic, readonly) BOOL isTomorrow;
/** 是否是后天 */
@property (nonatomic, readonly) BOOL isTheDayAfterTomorrow;
/** 是否是大后天 */
@property (nonatomic, readonly) BOOL isThreeDaysFromNow;
/** 是否是昨天 */
@property (nonatomic, readonly) BOOL isYesterday;
/** 是否是前天 */
@property (nonatomic, readonly) BOOL isThDayBeforeYesterday;

/** 当前日期与指定日期间，相差多少天 */
- (NSInteger)daysSince:(YLDateV2 *)date;

@end

/**
 日期组件类。
 @warning 仅用于通过组件生成 YLDateV2 使用。使用场景: 选择日期时，保存选择的类型以及数据
 --by zwh
 */
__attribute__((objc_subclassing_restricted))
@interface YLDateComponents : NSObject

/**
 特别需要注意的是: 如果是农历，在同一个新历年中可能出现两个相同的农历月日
 这种情况在年底与年初时出现
 例如: 1902年1月1日～1902年1月11日，对应农历为冬月廿二～腊月初二
 同样的: 1902年12月21日～1902年12月31日，对应的农历为冬月廿二～腊月初二
 此时构造出来的YLDateV2会选取年底的那个日期，即:
 component.isLunar = YES;
 component.year = 1902;
 component.month = 11;// 冬月
 component.day = 22; // 廿二
 YLDateV2 *date = [YLDateV2 dateFromDateComponents:component];
 NSLog(@"%@", date.solar); // 1902.12.21
 
 此外, 如果选择的月日导致跨年了, 日期会定位到下一年, 例如:
 component.isLunar = YES;
 component.year = 1902;
 component.month = 12;// 腊月
 component.day = 3; // 初三
 YLDateV2 *date = [YLDateV2 dateFromDateComponents:component];
 NSLog(@"%@", date.solar); // 1903.1.1
 NSLog(@"%ld", date.lunar.year.idx) // 1902
 */

/** 是否是农历 */
@property (nonatomic, getter=isLunar) BOOL lunar;
/** 年份 @warning 如果为农历，农历年份仅支持1900～2135年 */
@property (nonatomic) NSInteger year;
/** 月份 @warning month = 1 表示 正月/1月 */
@property (nonatomic) NSInteger month;
/** 是否是闰月 @warning 当且仅当 isLuanr 为 YES 时使用 */
@property (nonatomic, getter=isLeapMonth) BOOL leapMonth;
/** 日 @warning day = 1 表示 初一/1号 */
@property (nonatomic) NSInteger day;
/** 时 */
@property (nonatomic) NSInteger hour;
/** 分 */
@property (nonatomic) NSInteger minute;
/** 秒 */
@property (nonatomic) NSInteger second;

@end

NS_ASSUME_NONNULL_END
