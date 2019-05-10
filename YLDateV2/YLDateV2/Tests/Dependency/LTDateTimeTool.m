//
//  LTDateTimeTool.m
//  CenterWeather
//
//  Created by NineTonTech on 14-4-16.
//  Copyright (c) 2014年 ninetontech. All rights reserved.
//

#import "LTDateTimeTool.h"
#import "YLDate.h"
#import "GLCalendarCenter.h"


@implementation LTDateTimeTool

+(int)getWeekIndexByWeekStr:(NSString *)weekStr
{
    if (weekStr == nil && weekStr.length <=1) return -1;
    
    if ([weekStr isEqualToString:@"星期一"] || [weekStr isEqualToString:@"周一"]) return 1;
    
    if ([weekStr isEqualToString:@"星期二"] || [weekStr isEqualToString:@"周二"]) return 2;
    
    if ([weekStr isEqualToString:@"星期三"] || [weekStr isEqualToString:@"周三"]) return 3;
    
    if ([weekStr isEqualToString:@"星期四"] || [weekStr isEqualToString:@"周四"]) return 4;
    
    if ([weekStr isEqualToString:@"星期五"] || [weekStr isEqualToString:@"周五"]) return 5;
    
    if ([weekStr isEqualToString:@"星期六"] || [weekStr isEqualToString:@"周六"]) return 6;
    
    if ([weekStr isEqualToString:@"星期日"] || [weekStr isEqualToString:@"星期天"] || [weekStr isEqualToString:@"周日"]) return 0;
    
    return -1;
}

+(NSString *)getWeekStrByWeekIndex:(int)weekIndex Mode:(int)mode
{
    weekIndex = weekIndex % 7;
    switch (weekIndex) {
        case 1:
            return mode == 0? @"周一":@"星期一";
            break;
        case 2:
            return mode == 0? @"周二":@"星期二";
            break;
        case 3:
            return mode == 0? @"周三":@"星期三";
            break;
        case 4:
            return mode == 0? @"周四":@"星期四";
            break;
        case 5:
            return mode == 0? @"周五":@"星期五";
            break;
        case 6:
            return mode == 0? @"周六":@"星期六";
            break;
        case 0:
            return mode == 0? @"周日":@"星期天";
            break;
            
        default:
            return mode == 0? @"--":@"---";
            break;
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+(BOOL)isDayTime
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger uinitFlags = NSCalendarUnitHour;
    NSDateComponents *comps = [calendar components:uinitFlags fromDate:currentDate];
    NSInteger hour = [comps hour];
    if (hour >= 19 || hour <= 6) {
        return NO;
    }else return YES;
    
}

+(NSInteger)currentHour
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger uinitFlags = NSCalendarUnitHour;
    NSDateComponents *comps = [calendar components:uinitFlags fromDate:currentDate];
    return [comps hour];
}

+(NSArray *)getCurrentTimeArray{
    NSDate *lDate=[NSDate date];
    NSDateFormatter *lFormatter=[[NSDateFormatter alloc]init];
    lFormatter.dateFormat=@"yyyy-MM-dd-hh-mm-ss";
    if(![GLCalendarCenter sharedInstance].isStandardCalendar){
    NSCalendar* calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
    lFormatter.calendar = calendar;
    }
    NSString *lTime=[lFormatter stringFromDate:lDate];
    NSArray *lArray=[lTime componentsSeparatedByString:@"-"];
    return lArray;
}

+(NSInteger)currentWeekDay
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger uinitFlags = NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:uinitFlags fromDate:currentDate];
    return [comps weekday];
}
#pragma clang diagnostic pop
+(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    if(![GLCalendarCenter sharedInstance].isStandardCalendar){
    NSCalendar* calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
    df.calendar = calendar;
    }
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *dt1 = [df dateFromString:date01];
    NSDate *dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
        default: break;
    }
    return ci;
}

+(int)compareWithDate:(NSDate*)date01 withDate:(NSDate*)date02{
    int ci;
    int days = [date01 hl_daysSinceDate:date02];
    if (days == 0) {
        ci = 0;
    }else if (days>0){
        ci = 1;
    }else{
        ci = -1;
    }
    return ci;
}

+(dateInterval)getIntervalOfDate:(NSString *)smallDate date:(NSString *)bigDate ofMode:(DateFormate)dateFormate{
    NSDateFormatter *lFormate = [[NSDateFormatter alloc] init];
    if(![GLCalendarCenter sharedInstance].isStandardCalendar){
    NSCalendar* calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
    lFormate.calendar = calendar;
    }
    switch (dateFormate) {
        case DateFormate_YYYYMMDDHHmmss:
            [lFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            break;
        case DateFormate_YYYYMMDD:
            [lFormate setDateFormat:@"yyyy-MM-dd"];
            break;
        case DateFormate_HHmmss:
            [lFormate setDateFormat:@"HH:mm:ss"];
            break;
        case DateFormate_YYYYMMDDHHmmss_c:
            [lFormate setDateFormat:@"yyyy年MM月dd日 HH点mm分ss秒"];
            break;
        case DateFormate_YYYYMMDD_c:
            [lFormate setDateFormat:@"yyyy年MM月dd日"];
            break;
        case DateFormate_HHmmss_c:
            [lFormate setDateFormat:@"HH点mm分ss秒"];
            break;
        case DateFormate_MMDDHHmm_c:
            [lFormate setDateFormat:@"MM月dd日 HH点mm分"];
            break;
            
        default:
            break;
    }
    
    NSDate *dt1 = [lFormate dateFromString:smallDate];
    NSDate *dt2 = [lFormate dateFromString:bigDate];
    
    NSTimeInterval interval = [dt2 timeIntervalSinceDate:dt1];
    dateInterval l ;
    
    l.secendInterval = 0;
    l.minuteInterval = 0;
    l.hourInterval = 0;
    l.dayInterval = 0;
    
    l.secendInterval = interval;
    l.minuteInterval = interval/60;
    l.hourInterval = l.minuteInterval/60;
    l.dayInterval = l.hourInterval/24;

    return l;
}

+(BOOL)ifTheSameDayOfDate1:(NSDate *)date1 date2:(NSDate *)date2{
    if ( date1.ylDay == date2.ylDay && date1.ylYear == date2.ylYear && date1.ylMonth == date2.ylMonth) {
        return YES;
    }
    return NO;
}


@end
