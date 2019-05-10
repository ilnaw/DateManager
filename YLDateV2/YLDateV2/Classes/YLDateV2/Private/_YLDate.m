//
//  _YLDate.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "_YLDate.h"

@implementation _YLDate

+ (instancetype)dateWithDate:(NSDate *)date {
    // Subclass should implement
    return nil;
}

- (NSDate *)date { return _date.copy; }
- (NSDateComponents *)components {
    if (!_components) { _components = [self.class componentsFromDate:_date]; }
    return _components.copy;
}

+ (NSCalendar *)calendar {
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

+ (NSDateComponents *)componentsFromDate:(NSDate *)date {
    return [self.calendar components:NSCalendarUnitYear    | NSCalendarUnitMonth          |
                                     NSCalendarUnitDay     | NSCalendarUnitHour           |
                                     NSCalendarUnitMinute  | NSCalendarUnitSecond         |
                                     NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal |
                                     NSCalendarUnitWeekOfYear
                            fromDate:date];
}

@end
