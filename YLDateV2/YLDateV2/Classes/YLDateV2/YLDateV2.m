//
//  YLDateV2.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDateV2.h"
#import "NSDate+YL.h"
#import "solarlunar.h"

@implementation YLDateV2

@synthesize solar = _solar, lunar = _lunar, almanac = _almanac;

+ (instancetype)dateWithDate:(NSDate *)date {
    if (!date) { return nil; }
    YLDateV2 *yl = YLDateV2.new;
    yl->_date = date;
    return yl;
}

+ (instancetype)dateWithYear:(NSInteger)y
                       month:(NSInteger)M
                         day:(NSInteger)d
                        hour:(NSInteger)H
                      minute:(NSInteger)m
                      second:(NSInteger)s {
    NSDateComponents *components = [self componentsFromDate:NSDate.date];
    components.year = y;
    components.month = M;
    components.day = d;
    components.hour = H;
    components.minute = m;
    components.second = s;
    return [self dateFromComponents:components];
}

+ (instancetype)dateFromComponents:(NSDateComponents *)components {
    NSDate *date = [self.calendar dateFromComponents:components];
    return [self dateWithDate:date];
}

+ (instancetype _Nullable)localeDateFromGMT:(YLDateV2 *)GMTDate {
    NSInteger seconds = [NSTimeZone.systemTimeZone secondsFromGMTForDate:GMTDate.date];
    return [NSDate dateWithTimeInterval:seconds sinceDate:GMTDate.date].yl;
}

+ (instancetype _Nullable)dateFromString:(NSString *)date
                                  format:(NSString *)format {
    if (format.length <= 0) { return nil; }
    
    static NSMutableDictionary<NSString *, NSDateFormatter *> *formatters = nil;
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatters = NSMutableDictionary.new;
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSDateFormatter *formatter = formatters[format];
    if (!formatter) {
        formatter = NSDateFormatter.new;
        formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        formatter.dateFormat = format;
        formatters[format] = formatter;
    }
    dispatch_semaphore_signal(semaphore);
    return [YLDateV2 dateWithDate:[formatter dateFromString:date]];
}

+ (instancetype _Nullable)dateFromDateComponents:(YLDateComponents *)components {
    if (!components.isLunar) {
        return [self dateWithYear:components.year
                            month:components.month
                              day:components.day
                             hour:components.hour
                           minute:components.minute
                           second:components.second];
    }
    return [self _dateFromLunar:components];
}

- (YLSolar *)solar {
    if (!_solar) { _solar = [YLSolar dateWithDate:self.date]; }
    return _solar;
}

- (YLLunar *)lunar {
    if (!_lunar) { _lunar = [YLLunar dateWithDate:self.date]; }
    if (!_lunar.isValid) { return nil; }
    return _lunar;
}

- (YLAlmanac *)almanac {
    if (!_almanac) { _almanac = [YLAlmanac dateWithDate:self.date]; }
    if (!self.lunar) { return nil; }
    return _almanac;
}

#pragma mark - 日期操作
- (YLDateV2 *)daysOffset:(NSInteger)days {
    NSTimeInterval interval = days * 24 * 60 * 60;
    NSDate *date = [NSDate dateWithTimeInterval:interval
                                      sinceDate:self.date];
    return [YLDateV2 dateWithDate:date];
}

- (YLDateV2 *)monthsOffset:(NSInteger)months {
    solar_calendar now = solar_creat_date((int)self.solar.year, (int)self.solar.month, (int)self.solar.day);
    NSInteger year = self.solar.year + months / 12;
    NSInteger month = self.solar.month + months % 12;
    NSInteger day = self.solar.day;
    NSInteger maxDay = [YLSolar maxDayOf:year month:month];
    day = MIN(day, maxDay);
    
    solar_calendar after = solar_creat_date((int)year, (int)month, (int)day);
    NSInteger days = after - now;
    return [self daysOffset:days];
}

- (BOOL)isTheSameDay:(YLDateV2 *)date {
    return self.solar.year  == date.solar.year &&
           self.solar.month == date.solar.month &&
           self.solar.day   == date.solar.day;
}

- (BOOL)isWeekend { return self.solar.weekday == 0 || self.solar.weekday == 6; }
- (BOOL)isToday { return [self isTheSameDay:NSDate.date.yl]; }
- (BOOL)isTomorrow {
    YLDateV2 *today = NSDate.date.yl;
    return [self isTheSameDay:[today daysOffset:1]];
}

- (BOOL)isTheDayAfterTomorrow {
    YLDateV2 *today = NSDate.date.yl;
    return [self isTheSameDay:[today daysOffset:2]];
}

- (BOOL)isThreeDaysFromNow {
    YLDateV2 *today = NSDate.date.yl;
    return [self isTheSameDay:[today daysOffset:3]];
}

- (BOOL)isYesterday {
    YLDateV2 *today = NSDate.date.yl;
    return [self isTheSameDay:[today daysOffset:-1]];
}

- (BOOL)isThDayBeforeYesterday {
    YLDateV2 *today = NSDate.date.yl;
    return [self isTheSameDay:[today daysOffset:-2]];
}

- (NSInteger)daysSince:(YLDateV2 *)date {
    solar_calendar now = solar_creat_date((int)self.solar.year, (int)self.solar.month, (int)self.solar.day);
    solar_calendar another = solar_creat_date((int)date.solar.year, (int)date.solar.month, (int)date.solar.day);
    return (NSInteger)(now - another);
}

#pragma mark - Private
/** 使用农历初始化 */
+ (instancetype)_dateFromLunar:(YLDateComponents *)lunar {
    NSDate *date = [YLLunar dateWithYear:lunar.year
                             isLeapMonth:lunar.isLeapMonth
                                   month:lunar.month
                                     day:lunar.day
                                    hour:lunar.hour
                                  minute:lunar.minute
                                  second:lunar.second];
    YLDateV2 *yl = [self dateWithDate:date];
    if (!yl) { return nil; }
    unsigned int yll = yl.lunar.isLeapMonth ? 1 : 0;
    unsigned int ll = lunar.isLeapMonth ? 1 : 0;
    // 校验
    if (yl.lunar.year      == lunar.year   &&
        yl.lunar.month.idx == lunar.month  &&
        yll == ll                          &&
        yl.lunar.day.idx   == lunar.day    &&
        yl.solar.hour      == lunar.hour   &&
        yl.solar.minute    == lunar.minute &&
        yl.solar.second    == lunar.second) {
        return yl;
    }
    return nil;
}

@end

@implementation YLDateComponents @end
