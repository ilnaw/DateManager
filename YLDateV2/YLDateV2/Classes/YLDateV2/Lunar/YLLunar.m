//
//  YLLunar.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLLunar.h"
#import "YLLunarData.h"
#import "solarlunar.h"
#import "YLSolar.h"

@implementation YLLunar

+ (instancetype)dateWithDate:(NSDate *)date {
    YLLunar *lunar = YLLunar.new;
    lunar->_date = date;
    if (lunar.isValid) { [lunar _calculation]; }
    return lunar;
}

+ (NSArray<NSString *> *)months {
    return @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月",
             @"七月", @"八月", @"九月", @"十月", @"冬月", @"腊月"];
}

+ (NSArray<NSString *> *)days {
    return @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
             @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
             @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"];
}

+ (NSArray<NSString *> *)animals {
    return @[@"鼠", @"牛", @"虎", @"兔", @"龙", @"蛇", @"马", @"羊", @"猴", @"鸡", @"狗", @"猪"];
}

+ (BOOL)isLunarValid:(NSDate *)date {
    NSDateComponents *components = [self componentsFromDate:date];
    return [self _isValid:components.year];
}

- (BOOL)isValid {
    return [YLLunar _isValid:self.components.year];
}

+ (NSDate * _Nullable)dateWithYear:(NSInteger)y
                       isLeapMonth:(BOOL)isLeap
                             month:(NSInteger)M
                               day:(NSInteger)d
                              hour:(NSInteger)H
                            minute:(NSInteger)m
                            second:(NSInteger)s {
    if (![self _isValid:y]) {
        if (y != YLMinYear - 1) { // 从农历转换到新历，最小可支持农历年为1899
            return nil;
        }
    }
    NSDateComponents *components = [self componentsFromDate:NSDate.date];
    components.hour = H;
    components.minute = m;
    components.second = s;
    
    unsigned int lunarHex = YLLunarTable[y - YLMinYear + 1];
    unsigned int chuyi = lunarHex & 0xFF; // 大年初一
    lunarHex >>= 8;
    unsigned int leapMonth = lunarHex & 0xF;
    lunarHex >>= 4;
    unsigned int days = chuyi; // 从初一开始计算天数
    for (unsigned int i = 1; i < M; i++) {
        days += (((lunarHex >> (13 - i)) & 0x1) + 29);
        if (!isLeap) {
            if (i == leapMonth) {
                days += ((lunarHex & 0x1) + 29);
            }
        }
    }
    unsigned int maxDaysInThisMonth = (((lunarHex >> (13 - M)) & 0x1) + 29);
    if (isLeap) {
        if (leapMonth != M) { return nil; } // 今年没有这个闰月, 数据错误
        days += maxDaysInThisMonth;
        maxDaysInThisMonth = (lunarHex & 0x1) + 29;
    }
    
    if (d > maxDaysInThisMonth) { return nil; } // 该月日期大于最大天数, 数据错误
    days += (d - 1);
    solar_calendar day = solar_creat_date((int)y, 1, 1); // 以1.1日作为基准日期
    day += days;
    components.year  = solar_get_year(day);
    components.month = solar_get_month(day);
    components.day   = solar_get_day(day);
    
    return [self.calendar dateFromComponents:components];
}

#pragma mark - Private
+ (BOOL)_isValid:(NSInteger)year {
    return year >= YLMinYear && year <= YLMaxYear;
}

// 推算农历数据
- (void)_calculation {
    int year = (int)self.components.year;
    NSInteger yearOffset = year - 1899; // 基准日期 1899 年 属猪(11)
    solar_calendar this = solar_creat_date(year, (int)self.components.month, (int)self.components.day);
    solar_calendar newYearsDay = solar_creat_date(year, 1, 1);
    NSInteger dayOffset = this - newYearsDay;
    
    unsigned int lunarHex = YLLunarTable[year - YLMinYear + 1];
    unsigned int chuyi = lunarHex & 0xFF; // 大年初一
    // 生肖年份按照正月初一确定
    if (chuyi > dayOffset) {
        dayOffset += 365;
        if ([YLSolar isLeapYear:year - 1]) {
            dayOffset += 1;
        }
        lunarHex = YLLunarTable[year - YLMinYear];
        chuyi = lunarHex & 0xFF;
        yearOffset--; // 未到初一，年份减一年
        year--;
    }
    _year = year;
    NSInteger idx = (yearOffset + 11) % 12;
    _animal = [YLDateUnit unitWith:YLLunar.animals[idx]
                                idx:idx];
    
    lunarHex >>= 8;
    dayOffset -= chuyi;
    dayOffset += 1;
    unsigned int leapMonth = lunarHex & 0xF;
    lunarHex >>= 4;
    for (unsigned int i = 12; i > 0; i--) {
        unsigned int days = ((lunarHex >> i) & 0x1) + 29;
        unsigned int month = (13 - i);
        if (dayOffset <= days) {
            _maxDayCountsOfThisMonth = days;
            _month = [YLDateUnit unitWith:YLLunar.months[month - 1]
                                       idx:month];
            _day = [YLDateUnit unitWith:YLLunar.days[dayOffset - 1]
                                     idx:dayOffset];
            break;
        } else {
            dayOffset -= days;
            if (leapMonth != month) { continue; }
            
            days = (lunarHex & 0x1) + 29;
            if (dayOffset <= days) {
                _isLeapMonth = YES;
                _maxDayCountsOfThisMonth = days;
                _month = [YLDateUnit unitWith:YLLunar.months[month - 1]
                                           idx:month];
                _day = [YLDateUnit unitWith:YLLunar.days[dayOffset - 1]
                                         idx:dayOffset];
                break;
            } else {
                dayOffset -= days;
                _isLeapMonth = NO;
            }
        }
    }
}

@end
