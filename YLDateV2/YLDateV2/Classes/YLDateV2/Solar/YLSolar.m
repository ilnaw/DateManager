//
//  YLSolar.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLSolar.h"
/**
 星座日期(前后两个日期构成开始与结束日期)
 例：
 119, 218 表示 1.20~2.18, 该时间段为水瓶座
 218, 320 表示 2.19~3.20, 该时间段为双鱼座
 */
static unsigned int _YLConstellationDate[12] = {119, 218, 320, 419, 520, 621, 722, 822, 922, 1023, 1122, 1221};

@implementation YLSolar

@synthesize constellation = _constellation;

+ (instancetype)dateWithDate:(NSDate *)date {
    YLSolar *solar = YLSolar.new;
    solar->_date = date;
    return solar;
}

+ (NSArray<NSString *> *)constellations {
    return @[@"白羊座", @"金牛座", @"双子座", @"巨蟹座", @"狮子座", @"处女座",
             @"天秤座", @"天蝎座", @"射手座", @"摩羯座", @"水瓶座", @"双鱼座"];
}

+ (NSArray<NSString *> *)constellationDateRanges {
    static NSMutableArray<NSString *> *ranges = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ranges = NSMutableArray.new;
        for (int i = 0; i < 12; i++) {
            int s = (i + 2) % 12;
            int l = _YLConstellationDate[s] + 1; // 因为数组中的日期为上一个星座的结束日期，+1 便变成当前星座的开始日期
            int h = _YLConstellationDate[(s + 1) % 12];
            [ranges addObject:[NSString stringWithFormat:@"%02d.%02d~%02d.%02d", l / 100, l % 100, h / 100, h % 100]];
        }
    });
    return ranges.copy;
}

- (BOOL)isLeapYear {
    NSInteger year = self.year;
    return [self.class isLeapYear:year];
}
- (NSInteger)year { return self.components.year; }
- (NSInteger)month { return self.components.month; }
- (NSInteger)day { return self.components.day; }
- (NSInteger)hour { return self.components.hour; }
- (NSInteger)minute { return self.components.minute; }
- (NSInteger)second { return self.components.second; }
- (NSInteger)weekday { return self.components.weekday - 1; }
- (NSInteger)weekdayOrdinal { return self.components.weekdayOrdinal; }
- (NSInteger)weekOfYear { return self.components.weekOfYear; }

- (NSInteger)maxDayCountsOfThisMonth {
    return [self.class maxDayOf:self.year
                          month:self.month];
}

- (NSInteger)maxDayCountsOfThisYear {
    return self.isLeapYear ? 366 : 365;
}

- (YLDateUnit *)constellation {
    if (!_constellation) {
        NSInteger idx = [self _idxOfConstellation];
        _constellation = [YLDateUnit unitWith:self.class.constellations[idx]
                                          idx:idx];
    }
    return _constellation;
}

#pragma mark - Tools
+ (BOOL)isLeapYear:(NSInteger)year {
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

+ (NSInteger)maxDayOf:(NSInteger)year
                month:(NSInteger)month {
    NSInteger days[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2 && [self isLeapYear:year]) { return 29; } // 闰年 2月
    return days[month - 1];
}

#pragma mark - Private
- (NSInteger)_idxOfConstellation {
    NSInteger idx = 9;
    NSInteger date = self.month * 100 + self.day;
    for (NSInteger i = 0; i < 12; i++) {
        unsigned int d = _YLConstellationDate[i];
        if (date > d) {
            idx++;
        } else {
            break;
        }
    }
    return idx % 12;
}
@end
