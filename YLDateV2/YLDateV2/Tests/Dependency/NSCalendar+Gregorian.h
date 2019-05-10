//
//  NSCalendar+Gregorian.h
//  CalendarOS7
//
//  Created by 严明俊 on 16/6/20.
//  Copyright © 2016年 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (Gregorian)

+ (instancetype)gregorianCalendar;

+ (instancetype)chineseCalendar;

- (NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

@end
