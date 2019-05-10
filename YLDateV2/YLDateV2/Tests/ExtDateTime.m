//
//  ExtDateTime.m
//  Calendar
//
//  Created by Jasonluo on 12/9/11.
//  Copyright (c) 2011 YouLoft.Com. All rights reserved.
//

#import "ExtDateTime.h"
#import "YLDate.h"
#import "Lunar.h"

@implementation ExtDateTime
@synthesize Year,Month,Day,Hour,Minute,Second,IsLunar,IsLeap,IsAllDay;
@synthesize lunarMgr;



- (id)copyWithZone:(NSZone *)zone
{
    ExtDateTime *dt = [[ExtDateTime alloc] init];
    dt.Year = self.Year;
    dt.Month = self.Month;
    dt.Day = self.Day;
    dt.Hour = self.Hour;
    dt.Minute = self.Minute;
    dt.Second = self.Second;
    dt.IsAllDay = self.IsAllDay;
    dt.IsLunar = self.IsLunar;
    dt.IsLeap = self.IsLeap;
    return dt;
}

+(ExtDateTime*) dateTimeWithNSDate:(YLDate *)date {
    ExtDateTime *value = [[ExtDateTime alloc] init];
    NSDateComponents *comp2 = [date ylInstantDateComponents];
    value.Year = [comp2 year];
    value.Month = [comp2 month];
    value.Day = [comp2 day];
    value.Hour = [comp2 hour];
    value.Minute = [comp2 minute];
    value.Second = [comp2 second];
    value.IsLunar = NO;
    value.IsLeap = NO;
    if (value.Year < 1900 || value.Year > 2100) {
        value.Year = 1900;
        value.Month = 1;
        value.Day = 1;
    }
    return value;
}
+(ExtDateTime*) dateOfYear:(NSInteger)year ByOffset:(NSInteger)offset {
    if (offset < 0) {
        return [[ExtDateTime alloc] init];
    }
    ExtDateTime *date = [[ExtDateTime alloc] init];
    date.Hour = 12;
    date.Minute = 0;
    date.Second = 0;
    
    date.Year = year;
    int leap = (LEAP(year)?1:0);
    if (offset < 31) {
        date.Month = 1;
        date.Day = offset;
    }
    else if (offset <31+28+leap) {
        date.Month = 2;
        date.Day = offset - 31;
    }
    else if (offset < 31+28+leap+31) {
        date.Month = 3;
        date.Day = offset - 31 - 28-leap;
    }
    else if (offset < 31+28+leap+31+30) {
        date.Month = 4;
        date.Day = offset - 31-28-leap-31;
    }
    else if (offset < 31+28+leap+31+30+31) {
        date.Month = 5;
        date.Day = offset - 31-28-leap-31 - 30;
    }
    else if (offset < 31+28+leap+31+30+31+30) {
        date.Month = 6;
        date.Day = offset - 31-28-leap-31-30-31;
    }
    else if (offset < 31+28+leap+31+30+31+30+31){
        date.Month = 7;
        date.Day = offset - 31-28-leap-31-30-31-30;
    }
    else if (offset < 31+28+leap+31+30+31+30+31+31){
        date.Month = 8;
        date.Day = offset - 31-28-leap-31-30-31-30-31;
    }
    else if (offset < 31+28+leap+31+30+31+30+31+31+30){
        date.Month = 9;
        date.Day = offset - 31-28-leap-31-30-31-30-31-31;
    }
    else if (offset < 31+28+leap+31+30+31+30+31+31+30+31) {
        date.Month = 10;
        date.Day = offset - 31-28-leap-31-30-31-30-31-31-30;
    }
    else if (offset < 31+28+leap+31+30+31+30+31+31+30+31+30){
        date.Month = 11;
        date.Day = offset - 31-28-leap-31-30-31-30-31-31-30-31;
    }
    else {
        date.Month = 12;
        date.Day = offset - 31-28-leap-31-30-31-30-31-31-30-31-30;
    }
    date.Day+=1;
    return date;
}

// 1900-10-10 10:10:10 <=> numDate:19011111 & numTime:111111
+(ExtDateTime*) dateTimeWithNumDate:(NSInteger)numDate numTime:(NSInteger)numTime {
    ExtDateTime *date = [[ExtDateTime alloc] init];
    
    date.Year = numDate/10000-1;
    date.Month = (numDate- (date.Year+1) *10000)/100 -1;
    date.Day = numDate - (date.Year+1)*10000-(date.Month+1)*100-1;
    date.Hour = numTime/10000-1;
    date.Minute = (numTime-(date.Hour+1)*10000)/100-1;
    date.Second = numTime - (date.Hour+1)*10000 - (date.Minute+1)*100-1;
    
    return date;
}

-(NSInteger) numDate {
    return (self.Year+1)*10000+(self.Month+1)*100+ self.Day + 1;
}
-(NSInteger) numTime {
    return (self.Hour+1)*10000+(self.Minute+1)*100+ self.Second+1;
}

-(NSInteger) solarDayOffset {
    int dayCount = 0;
    switch (self.Month) {
        case 12:
            dayCount+=30;
        case 11:
            dayCount+=31;
        case 10:
            dayCount+=30;
        case 9:
            dayCount+=31;
        case 8:
            dayCount+=31;
        case 7:
            dayCount+=30;
        case 6:
            dayCount+=31;
        case 5:
            dayCount+=30;
        case 4:
            dayCount+=31;
        case 3:
            dayCount+=(LEAP(self.Year)?29:28);
        case 2:
            dayCount+=31;
        case 1:
            dayCount+=0;
            break;
        default:
            return -1;
    }
    return dayCount+self.Day-1;
}
-(NSInteger) solarDayCountInMonth {
    switch (self.Month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 4:
        case 6:
        case 9:
        case 11:
            return 30;
        case 2:
            return LEAP(self.Year)?29:28;
        default:
            return -1;
    }
}
-(NSInteger) solarDayCountInYear {
    return (LEAP(self.Year))?366:365;
}

-(NSInteger) solarDayIntervalSinceDate:(ExtDateTime*)date {
    if (date.IsLunar) {
        return -1;
    }
    ExtDateTime *tmp = [[ExtDateTime alloc] init];
    int dayCounts = -1;
    if ([self numDate]<[date numDate]) {
        return -[date solarDayIntervalSinceDate:self];
    }
    if (date.Year == self.Year) {
        dayCounts +=[self solarDayOffset] - [date solarDayOffset] +1;
    }
    else {
        dayCounts += [date solarDayCountInYear]-[date solarDayOffset]+[self solarDayOffset]+1;
        for (NSInteger i=date.Year+1; i<self.Year; i++) {
            tmp.Year = i;
            dayCounts += [tmp solarDayCountInYear];
        }
    }
    return dayCounts;
}
-(NSString*) solarStr {
    if (self.IsAllDay) {
        return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld",
                (long)MAX(0, self.Year),(long)MAX(0, self.Month),(long)MAX(0,self.Day)];
    }
    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld",
            (long)MAX(0, self.Year),(long)MAX(0, self.Month),(long)MAX(0,self.Day),(long)MAX(0,self.Hour),(long)MAX(0,self.Minute)];
}
-(NSString*) descOfDateTime {
    @try {
        if (self.IsLunar) {
            if (!self.lunarMgr) {
                self.lunarMgr = [[Lunar alloc] init];
            }
            return [self.lunarMgr lunarStrFromLunar:self];
        }
        return [self solarStr];
    }
    @catch (NSException *exception) {
        return @"error";
    }
}
-(YLDate *) nsDateValue {
    ExtDateTime *solar = self;
    if (self.IsLunar) {
        if (!self.lunarMgr) {
            self.lunarMgr = [[Lunar alloc] init];
        }
        solar = [self.lunarMgr solarFromLunar:self];
    }
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *cp = [cal components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond fromDate:[NSDate date]];
    [cp setYear:solar.Year];
    [cp setMonth:solar.Month];
    [cp setDay:solar.Day];
    [cp setHour:solar.Hour];
    [cp setMinute:solar.Minute];
    [cp setSecond:solar.Second];
    NSDate *date = [cal dateFromComponents:cp];
    YLDate *yldate = [YLDate ylDateWithDate:date];
    return yldate;
}
-(BOOL) isLaterThanDate:(ExtDateTime*)date {
    if (([self numDate] > [date numDate])||([self numDate] == [date numDate] && [self numTime] >= [date numTime])) {
        return YES;
    }
    return NO;
}

-(BOOL) isSameDateWithDate:(ExtDateTime*)date {
    return (self.Year == date.Year && self.Month == date.Month && self.Day == date.Day);
}
-(id) copy {
    ExtDateTime *dt = [[ExtDateTime alloc] init];
    dt.Year = self.Year;
    dt.Month = self.Month;
    dt.Day = self.Day;
    dt.Hour = self.Hour;
    dt.Minute = self.Minute;
    dt.Second = self.Second;
    dt.IsAllDay = self.IsAllDay;
    dt.IsLunar = self.IsLunar;
    dt.IsLeap = self.IsLeap;
    return dt;
}
@end
