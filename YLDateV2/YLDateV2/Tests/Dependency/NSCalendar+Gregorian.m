//
//  NSCalendar+Gregorian.m
//  CalendarOS7
//
//  Created by 严明俊 on 16/6/20.
//  Copyright © 2016年 YouLoft. All rights reserved.
//

#import "NSCalendar+Gregorian.h"

@implementation NSCalendar (Gregorian)

+ (instancetype)chineseCalendar {
    static NSCalendar *chineseCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    });
    return chineseCalendar;
}

+ (NSCalendar *)gregorianCalendar {
    static NSCalendar *gregorianCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return gregorianCalendar;
}

- (NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSCalendarUnit units = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp1 = [self components:units fromDate:startDate];
    NSDateComponents *comp2 = [self components:units fromDate:endDate];
    [comp1 setHour:12];
    [comp2 setHour:12];
    NSDate *date1 = [self dateFromComponents: comp1];
    NSDate *date2 = [self dateFromComponents: comp2];
    return [[self components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0] day];
}

@end
