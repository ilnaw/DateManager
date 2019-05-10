//
//  NSDate_Custom.h
//  Calendar
//
//  Created by Jasonluo on 11-5-13.
//  Copyright 2011 YouLoft.Com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Custom)
typedef struct {
    int dayInterval;
    int hourInterval;
    int minuteInterval;
    int secendInterval;
}dateInterval;
typedef enum{
    
    DateFormate_YYYYMMDDHHmmss = 1,  //2014-02-23 13:33:13
    DateFormate_YYYYMMDD,  //2014-02-23
    DateFormate_HHmmss,  //13:33:13
    DateFormate_YYYYMMDDHH, //2014-02-23 13
    
    DateFormate_YYYYMMDDHHmmss_c,  //2014年02月23日 13时33分13秒
    DateFormate_YYYYMMDD_c,  //2014年 02月 23日
    DateFormate_HHmmss_c,   //13时 33分 13秒
    
    DateFormate_MMDDHHmm_c, //02月23日 13时33分
    
    DateFormate_YYYYMMggDDHHmmsszzz,
    DateFormate_YYYYMMDDHHmm_c //2014年02月23日 13时33分
    
}DateFormate;
+(NSDate*) ylDateWithYear:(int)year Month:(int)month Day:(int)day Hour:(int)hour Minute:(int)minute Second:(int)second;
+(NSDate*) ylDateFromComponents:(NSDateComponents*)components;
+(NSDate*) ylDateFromString:(NSString*)date WithFormat:(NSString*)format;
+(NSDate*) ylLocaleDateFromGMT:(NSDate*)gmtDate;
+(BOOL) ylIsDaylightSavingTime;
// hyd
+(NSDate*) dateFromString:(NSString*)date WithFormat:(NSString*)format;
+(NSDate*) dateFromStringRewrite:(NSString*)date WithFormat:(NSString*)format;


+ (NSDate *)currentDateWithTimeZone:(NSInteger)timeZone;


-(int) hl_daysSinceDate:(NSDate*)anotherDate;
- (NSString *)stringWithFormat:(NSString *)format;

-(NSDateComponents*) ylDateComponents;

-(int) ylYear;
-(int) ylMonth;
-(int) ylDay;
-(int) ylHour;
-(int) ylMinute;
-(int) ylSecond;
-(int) ylWeekday;
-(int) ylWeekdayOrdinal;
-(int) ylWeekOfYear;
-(int) ylMaxDayCountsOfThisMonth;
-(int) ylMaxDayCountsOfThisYear;
-(NSDate*) ylAddDays:(int)days;
-(int) ylDaysSinceDate:(NSDate*)anotherDate;
-(int) ylChineseNumHour;

-(BOOL) ylIsSameDateWithDate:(NSDate*)date;
-(NSDateComponents*) ylInstantDateComponents;

-(NSDate*) addDays:(int)days;
//返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterDay:(NSInteger)day;
@end
