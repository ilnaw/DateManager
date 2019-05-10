/*!
 @header YLDate.m
 @abstract 日期类工具
 @author Created by HuangZhenPeng .
 @version 4.5.4 2014/2/18 Creation
 Copyright © 2014年 YouLoft. All rights reserved.
 */


#import "YLDate.h"
#import "ExtDateTime.h"
#import "ExtDayInfo.h"
#import "Lunar.h"
//#import <libkern/OSAtomic.h>  // 没必要引入

#import "NSDate_Custom.h"
#import "solarlunar.h"
#import "LTDateTimeTool.h"     // 九宫飞星使用，但用处不大
#ifndef isLeapYear
#define isLeapYear(x) ((x) % 400 == 0)||((x) % 4 == 0 && (x) % 100 != 0)
#endif
static const int MINYEAR = 1900;
static const int MAXYEAR = 2099;
@implementation YLDate

- (BOOL)isLeapYear {
    NSInteger ylYear = self.ylYear;
    return isLeapYear(ylYear);
}

-(NSDate*) date {
    return _date;
}
-(NSDateComponents*) components {
    return _components;
}

-(id)initWithDate:(NSDate*)date {
    self = [super init];
    if (self)
    {
        _date = date;
    }
    return self;
}

+(YLDate *) ylDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    YLDate *ylDate = [[YLDate alloc] initWithDate:date];
    return ylDate;
}

+(YLDate *) ylDateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day Hour:(NSInteger)hour Minute:(NSInteger)minute Second:(NSInteger)second
{
    NSDateComponents *cp = [[YLDate ylDateWithDate:[NSDate date]] ylInstantDateComponents];//[[NSDate date] ylInstantDateComponents];
    [cp setYear:year];
    [cp setMonth:month];
    [cp setDay:day];
    [cp setHour:hour];
    [cp setMinute:minute];
    [cp setSecond:second];
    return [YLDate ylDateFromComponents:cp];
}

+(YLDate *) ylDateFromComponents:(NSDateComponents*)components {
    NSDate *date = [[YLDate ylCalendarManager] dateFromComponents:components];
    return [YLDate ylDateWithDate:date];
}

+(YLDate *) ylDateFromString:(NSString*)date WithFormat:(NSString*)format {
    if (!format) return nil;

    static NSMutableDictionary *dic = nil;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t semaphore;
    dispatch_once(&onceToken, ^{
        dic = [[NSMutableDictionary alloc] init];
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSDateFormatter *dateFormatter = [dic objectForKey:format];
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [dateFormatter setCalendar:cal];
        [dateFormatter setDateFormat:format];
        
        [dic setObject:dateFormatter forKey:format];
    }
    dispatch_semaphore_signal(semaphore);
    
	NSDate *Date = [dateFormatter dateFromString:date];
    YLDate *yldate = [YLDate ylDateWithDate:Date];
	return yldate;
}

+(YLDate *) ylLocaleDateFromGMT:(YLDate *)gmtDate {
	NSInteger iSecondsFromGMT = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:gmtDate.date];
	return [YLDate ylDateWithDate:[NSDate dateWithTimeInterval:iSecondsFromGMT sinceDate:gmtDate.date]];
}

+(BOOL) ylIsDaylightSavingTime {
    return [[YLDate ylCalendarManager].timeZone isDaylightSavingTime];
}

//static YLDCCache *manager = nil;
//+(YLDCCache*) ylCacheManager {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        manager = [YLDCCache new];
//    });
//    return manager;
//}

+(NSCalendar*) ylCalendarManager {
    static NSCalendar *calManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calManager = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return calManager;
}

+(YLDate *) ylEasterDayOfYear:(NSInteger) year
{
    NSInteger M = 24;
    NSInteger N = 5;
    NSInteger Y = year;
    NSInteger a = Y % 19;
    NSInteger b = Y % 4;
    NSInteger c = Y % 7;
    NSInteger d = (19 * a + M) % 30;
    NSInteger e = (2*b + 4*c + 6*d + N) % 7;
    
    if ((d + e) < 10) {
        return [YLDate ylDateWithYear:Y Month:3 Day:d + e + 22 Hour:12 Minute:0 Second:0];
    }else
    {
        return [YLDate ylDateWithYear:Y Month:4 Day:d + e - 9 Hour:12 Minute:0 Second:0];
    }
}

+(NSInteger) ylBEYearWithDate:(YLDate *) date
{
//    ExtDateTime *newLunar = [[ExtDayInfo extDayInfoManager].lunarMgr lunarFromSolar:[ExtDateTime dateTimeWithNSDate:date]];
//    if (newLunar.Month > 4) {
//        return date.ylYear + kYLDateBEOffset + 1;
//    }else if (newLunar.Month == 4)
//    {
//        if (newLunar.Day >= 8) {
//            return date.ylYear + kYLDateBEOffset + 1;
//        }else return date.ylYear + kYLDateBEOffset;
//    }else
//    {
//        return date.ylYear + kYLDateBEOffset ;
//    }
    return date.ylYear + kYLDateBEOffset;
}

-(BOOL) ylIsSameDateWithDate:(YLDate *)date {
    NSDateComponents *selfcp = [self ylDateComponents];
    NSDateComponents *othercp = [date ylDateComponents];
    BOOL result = NO;
    if ([selfcp year] == [othercp year] && [selfcp month] == [othercp month] && [selfcp day] == [othercp day]) {
        result = YES;
    }

    return result;
}

-(NSDateComponents*) ylInstantDateComponents {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dc = [cal components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond|kCFCalendarUnitWeekday|kCFCalendarUnitWeekdayOrdinal|kCFCalendarUnitWeekOfYear fromDate:self.date];
    return dc;
}

-(NSDateComponents*) ylDateComponents{
    if (!self.components) {
        _components = [[YLDate ylCalendarManager] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond|kCFCalendarUnitWeekday|
                       kCFCalendarUnitWeekdayOrdinal|kCFCalendarUnitWeekOfYear fromDate:self.date];
    }
    return [self.components copy];
}

-(NSInteger) ylYear {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp year];
    return result;
}
-(NSInteger) ylMonth {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp month];
    return result;
}
-(NSInteger) ylDay {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp day];
    return result;
}
-(NSInteger) ylHour {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp hour];
    return result;
}
-(NSInteger) ylMinute {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp minute];
    return result;
}
-(NSInteger) ylSecond {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp second];
    return result;
}
-(NSInteger) ylWeekday {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp weekday]-1;
    return result;
}
-(NSInteger) ylWeekdayOrdinal {
    NSDateComponents *cp = [self ylDateComponents];
    NSInteger result = [cp weekdayOrdinal];
    return result;
}

-(NSInteger) ylWeekOfYear {
    NSInteger iWeekOfYear = 0;
    NSDateComponents *cp = [self ylDateComponents];
    if ([cp respondsToSelector:@selector(weekOfYear)]) {
        iWeekOfYear = [cp weekOfYear];
    }
    else {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [outputFormatter setCalendar:cal];
        [outputFormatter setDateFormat:@"ww"];
        iWeekOfYear = [[outputFormatter stringFromDate:self.date] intValue];
    }
	return iWeekOfYear;
}

-(NSInteger) ylMaxDayCountsOfThisMonth {
	int arrDaysOfMonth[12] = { 31,isLeapYear([self ylYear])?29:28,31,30,31,30,31,31,30,31,30,31 };
	return arrDaysOfMonth[[self ylMonth]-1];
}
-(NSInteger) ylMaxDayCountsOfThisYear {
	return isLeapYear([self ylYear])?366:365;
}

-(YLDate *) ylAddDays:(NSInteger)days {
    NSTimeInterval dayCounts = days*24*60*60.0;
	return  [YLDate ylDateWithDate:[NSDate dateWithTimeInterval:dayCounts sinceDate:self.date]];
}

- (YLDate *) ylAddMonths: (NSInteger) months {
    YLDate *addedDate = nil;
    
    NSInteger year = self.ylYear;
    NSInteger month = self.ylMonth;
    NSInteger originDay = self.ylDay;
    NSInteger hour = self.ylHour;
    NSInteger minute = self.ylMinute;
    NSInteger second = self.ylSecond;
    
    NSInteger yearDiff = months / 12;
    NSInteger monthDiff = months % 12;
    year += yearDiff;
    month += monthDiff;
    
    // N个月后的月首日
    YLDate *futureStartDate = [YLDate ylDateWithYear:year Month:month Day:1 Hour:hour Minute:minute Second:second];
    
    NSInteger maxDayInMonth = [futureStartDate ylMaxDayCountsOfThisMonth];
    NSInteger futureDay = MIN(originDay, maxDayInMonth);
    addedDate = [YLDate ylDateWithYear:year Month:month Day:futureDay Hour:hour Minute:minute Second:second];
    
    return addedDate;
}

-(NSInteger) ylDaysSinceDate:(YLDate *)anotherDate {
    BOOL betterUse = NO;
    if ([anotherDate ylHour] == [self ylHour] &&
        [anotherDate ylMinute] == [self ylMinute] &&
        [anotherDate ylSecond] == [self ylSecond]) {
        betterUse = YES;
    }
    if (betterUse) {
        return (NSInteger)(round(([self.date timeIntervalSinceDate:anotherDate.date]/60/60/24)));///17.10.10修改 日卡上的天数计算推入后台再次进入这里会少一天
    }
    
    NSDateComponents *cp1 = [anotherDate ylDateComponents];
    cp1.hour = 0;
    cp1.minute = 0;
    cp1.second = 0;
    
    NSDateComponents *cp2 = [self ylDateComponents];
    cp2.hour = 0;
    cp2.minute = 0;
    cp2.second = 0;
    
    NSTimeInterval time = [[YLDate ylDateFromComponents:cp2].date timeIntervalSinceDate:[YLDate ylDateFromComponents:cp1].date];
    return (NSInteger)(round((time/60/60/24)));
}

-(YLDate *) firstDayInMonth//该月第一天
{
    YLDate *firstDate = [self ylAddDays:1-[self ylDay]];//当月第一天
    NSDateComponents *cp2 = [firstDate ylDateComponents];
    [cp2 setHour:12];
    [cp2 setMinute:0];
    [cp2 setSecond:0];
    firstDate = [YLDate ylDateFromComponents:cp2];//当月第一天12点
    return firstDate;
}

-(NSInteger) ylChineseNumHour {
	switch ([self ylHour]) {
		case 23:
		case 0:
			return 0;
		case 1:
		case 2:
			return 1;
		case 3:
		case 4:
			return 2;
		case 5:
		case 6:
			return 3;
		case 7:
		case 8:
			return 4;
		case 9:
		case 10:
			return 5;
		case 11:
		case 12:
			return 6;
		case 13:
		case 14:
			return 7;
		case 15:
		case 16:
			return 8;
		case 17:
		case 18:
			return 9;
		case 19:
		case 20:
			return 10;
		case 21:
		case 22:
			return 11;
		default:
			return -1;
	}
}

-(NSString*)description {
    return [self.date description];
}

-(BOOL) isWeekend {
    NSInteger weekday = [self ylWeekday];
    
    return (weekday == 0 || weekday == 6);
}

- (BOOL)isToDay
{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    return [self ylIsSameDateWithDate:now];
    
}

- (BOOL)isYesterday
{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    YLDate *nextDay = [now ylAddDays:-1];
    
    return [self ylIsSameDateWithDate:nextDay];
}

- (BOOL)isTheDayBeforeYesterday
{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    YLDate *nextDay = [now ylAddDays:-2];
    
    return [self ylIsSameDateWithDate:nextDay];
}

- (BOOL)isNextDay
{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    YLDate *nextDay = [now ylAddDays:1];
    
    return [self ylIsSameDateWithDate:nextDay];
    
}

- (BOOL)isTheDayAfterTomorrow
{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    YLDate *nextDay = [now ylAddDays:2];
    
    return [self ylIsSameDateWithDate:nextDay];
}

- (BOOL)isTheThirdDay
{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    YLDate *nextDay = [now ylAddDays:3];
    
    return [self ylIsSameDateWithDate:nextDay];
}

- (NSString *)retCurrentWeekDays{
    NSInteger weekIndex = self.ylWeekday;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    if (weekIndex == 0) {//当天为周日会跑到下一周  453调整
        startIndex = - 6;
        endIndex = 0;
    }else{
        startIndex = 1 - weekIndex;
        endIndex = 7 - weekIndex;
    }
    YLDate *startDate = [YLDate ylDateWithDate: [self.date dateByAddingTimeInterval:startIndex * 60 * 60 * 24]];
    YLDate *endDate = [YLDate ylDateWithDate: [self.date dateByAddingTimeInterval:endIndex * 60 * 60 * 24]];
    NSString *retString = [NSString stringWithFormat:@"%ld月%ld日-%ld月%ld日",(long)startDate.ylMonth,(long)startDate.ylDay,(long)endDate.ylMonth,(long)endDate.ylDay];
    
    return retString;
}
/****************** 添加九宫飞星的算法 从黄历中搬过来 只支持1990-2099年**************************************/
/*
 24节气信息表
 
 //1900-2099
 
 (0-23) -> (小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪 冬至)
 
 数字表示该节气距离1月1日的天数
 
 */

static unsigned int TermTable[200][24]={
    
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1900
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,327,341,356,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,327,341,356,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1910
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,326,341,356,
    5,19,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,
    5,19,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,355,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,//1920
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,355,
    5,20,35,50,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1930
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1940
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,125,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1950
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,50,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,//1960
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1970
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,35,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,35,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1980
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,139,155,171,186,202,218,233,249,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,109,124,140,155,171,187,202,218,234,249,266,281,296,311,326,341,355,
    4,19,34,49,63,78,94,108,123,139,155,170,186,202,217,233,248,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//1990
    
    5,19,34,49,64,79,94,108,124,139,155,171,186,202,218,233,249,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    4,19,34,48,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//2000
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    4,19,34,48,63,78,93,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2010
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,341,355,//2020
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2030
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2040
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,
    4,19,33,48,63,78,93,108,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2050
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2060
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,//2070
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,279,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,279,295,310,325,339,354,
    4,19,33,48,63,78,93,108,124,139,155,171,186,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2080
    4,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,
    4,19,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2090
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,294,309,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,217,233,249,264,279,294,309,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354//2099
};

+(NSInteger)getYearFXOfDate:(YLDate *)date{
    NSInteger FX = 0; 
    NSInteger years = date.ylYear - 1864;
    NSDate *firstOfYear = [NSDate dateFromString:[NSString stringWithFormat:@"%ld-01-01 00:00:00",(long)date.ylYear] WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger liChunDays = TermTable[date.ylYear - 1900][2]; //立春到当年第一天天数
    NSInteger days = [date ylDaysSinceDate:[YLDate ylDateWithDate:firstOfYear]]; //当前日期到当年第一天天数
    
    if (days<liChunDays) {
        years -= 1;
    }
    int num = years%9;
    if (num == 0) {
        FX = 1;
    }else{
        FX = 10 - num;
    }
    
    return FX;
}

+(NSInteger)getMonthFXOfDate:(NSDate *)date{
    NSInteger FX = 0;
    DateTime dt = [YLDate initDateTimeWithNSDate:date];
    NSString *tgdzYearStr = [YLDate tgdzYearString:dt];
    NSString *dzYearStr = [tgdzYearStr substringFromIndex:1];
    NSString *lunarMonthStr = [YLDate lunarMonthString:dt];
    if (lunarMonthStr.length>2) {
        lunarMonthStr = [lunarMonthStr substringFromIndex:1];
    }
    
    NSString *str1 = @"子午卯酉";
    NSString *str2 = @"寅申巳亥";
    NSString *str3 = @"辰戌丑未";
    
    NSArray *monthArr = @[@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"冬月",@"腊月",];
    
    NSInteger monthIndex = [monthArr indexOfObject:lunarMonthStr];
    
    NSDate *firstOfYear = [NSDate dateFromString:[NSString stringWithFormat:@"%d-01-01 00:00:00",date.ylYear] WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger days = [date hl_daysSinceDate:firstOfYear];//当日是当年第几天
    NSInteger liChunDays = TermTable[date.ylYear-1900][2];
    NSArray *jiaZiArray = @[@"甲子",@"乙丑",@"丙寅",@"丁卯",@"戊辰",@"己巳",@"庚午",@"辛未",@"壬申",@"癸酉",@"甲戌",@"乙亥",@"丙子",@"丁丑",@"戊寅",@"己卯",@"庚辰",@"辛巳",@"壬午",@"癸未",@"甲申",@"乙酉",@"丙戌",@"丁亥",@"戊子",@"己丑",@"庚寅",@"辛卯",@"壬辰",@"癸巳",@"甲午",@"乙未",@"丙申",@"丁酉",@"戊戌",@"己亥",@"庚子",@"辛丑",@"壬寅",@"癸卯",@"甲辰",@"乙巳",@"丙午",@"丁未",@"戊申",@"己酉",@"庚戌",@"辛亥",@"壬子",@"癸丑",@"甲寅",@"乙卯",@"丙辰",@"丁巳",@"戊午",@"己未",@"庚申",@"辛酉",@"壬戌",@"癸亥",];
    if (days>=liChunDays&&[lunarMonthStr isEqualToString:@"腊月"]) {
        NSInteger dzIndex = [jiaZiArray indexOfObject:tgdzYearStr];
        NSInteger lIndex = (dzIndex-1)>=0?(dzIndex-1):59;
        tgdzYearStr = [jiaZiArray objectAtIndex:lIndex];
        dzYearStr = [tgdzYearStr substringFromIndex:1];
        
    }
    if ([str1 rangeOfString:dzYearStr].length>0) {
        FX = 8 - monthIndex;
    }else if ([str2 rangeOfString:dzYearStr].length>0){
        FX = 2 - monthIndex;
    }else if ([str3 rangeOfString:dzYearStr].length>0){
        FX = 5 - monthIndex;
    }
    
    if (FX<0) {
        FX = 9+FX;
    }
    if (FX == 0){
        FX = 9;
    }
    
    return FX;
}

+(DateTime)initDateTimeWithNSDate:(NSDate *)solarNSDate{
    
    DateTime dt;
    dt.Year = [solarNSDate ylYear];
    dt.Month = [solarNSDate ylMonth];
    dt.Day = [solarNSDate ylDay];
    dt.Hour = [solarNSDate ylHour];
    dt.Minute = [solarNSDate ylMinute];
    dt.Second = [solarNSDate ylSecond];
    dt.isLunarMonthLeap = NO;
    dt.Type = DateTimeTypeSolar;
    if (dt.Year<1899||dt.Year>2099) {
        dt.Year = [[NSDate date] ylYear];
    }
    return dt;
}
+(NSDate*) initNSDateWithDateTime:(DateTime)datetime{
    
    NSDate *date = nil;
    DateTime solar;
    if (DateTimeTypeLunar == datetime.Type) {
        solar = [YLDate solarFromLunar:datetime];
    }
    else {
        solar = datetime;
    }
    NSInteger year = solar.Year;
    date = [NSDate dateFromString:[NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld",
                                   (long)year,(long)solar.Month,(long)solar.Day,(long)solar.Hour,(long)solar.Minute]
                       WithFormat:@"yyyy-MM-dd HH:mm"];
    return date;
}
+(DateTime) solarFromLunar:(DateTime)lunar{
    
    DateTime solar;
    solar.Type = DateTimeTypeSolar;
    lunar_calendar lu;
    if (lunar.isLunarMonthLeap) {
        lu = lunar_creat_date((int)lunar.Year, (int)lunar.Month, (29 + monthInfo((int)lunar.Year, (int)lunar.Month, NO)));
    }
    else {
        lu = lunar_creat_date((int)lunar.Year, (int)lunar.Month, (int)lunar.Day);
    }
    solar_calendar so = lunar2solar(lu);
    int year,month,day;
    year = solar_get_year(so);
    month = solar_get_month(so);
    day = solar_get_day(so);
    
    NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%.4d-%.2d-%.2d",year,month,day] WithFormat:@"yyyy-MM-dd"];
    date = [date addDays:((lunar.isLunarMonthLeap)?(int)lunar.Day:0)];

    solar.Year = [date ylYear];
    solar.Month = [date ylMonth];
    solar.Day = [date ylDay];
    solar.Hour = lunar.Hour;
    solar.Minute = lunar.Minute;
    solar.Second = lunar.Second;
    solar.isLunarMonthLeap = NO;
    return solar;
}
+(int) dayOffsetOfTerm:(int)termIndex inYear:(int)year {
    
    if(year >= MINYEAR && year <= MAXYEAR && termIndex >-1 && termIndex < 24) {
        return TermTable[(year-MINYEAR)][termIndex];
    }
    return -1;
}
+(int) solarDayOffset:(NSDate*)d {
    
    int dayCount = 0;
    switch (d.ylMonth) {
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
            dayCount+=(LEAP(d.ylYear)?29:28);
        case 2:
            dayCount+=31;
        case 1:
            dayCount+=0;
            break;
        default:
            return -1;
    }
    return dayCount+d.ylDay-1;
}
+(NSString*) tgdzYearString:(DateTime)dt{
    
    @try {
        int t=0;
        int b=0;
        int referenceYear = 1899;
        NSDate* solarDate = [YLDate initNSDateWithDateTime:dt];
        int yearOffset = solarDate.ylYear - referenceYear;//2014-1899=115
        if ([YLDate dayOffsetOfTerm:2 inYear:solarDate.ylYear] > [YLDate solarDayOffset:solarDate]) {
            yearOffset -=1;
        }
        NSArray *tianGanTexts = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸",nil];
        
        NSArray *diZhiTexts = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
        t = (yearOffset+5)%10;
        b = (yearOffset+11)%12;
        int index = ((6*t-5*b)+60)%60;
        if (index > -1) {
            NSString* result = [NSString stringWithFormat:@"%@%@",[tianGanTexts objectAtIndex:index%10],
                                [diZhiTexts objectAtIndex:index%12]];
            return result;
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
}
+(NSString*) lunarMonthString:(DateTime)dt {
    
    @try{
        NSString *strLunarMonth;
        DateTime lunarDt;
        if (dt.Type==DateTimeTypeSolar) {
            lunarDt = [YLDate lunarFromSolar:dt];
        }else{
            lunarDt = dt;
        }
        NSArray *lunarMonthTexts = [NSArray arrayWithObjects:@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",
                                @"七月",@"八月",@"九月",@"十月",@"冬月",@"腊月",nil];
        if (lunarDt.isLunarMonthLeap) {
            //闰月
            strLunarMonth = [NSString stringWithFormat:@"闰%@",[lunarMonthTexts objectAtIndex:lunarDt.Month-1]];
        }else{
            strLunarMonth = [NSString stringWithFormat:@"%@",[lunarMonthTexts objectAtIndex:lunarDt.Month-1]];
        }
        return strLunarMonth;
    }@catch(NSException* ex){
        return nil;
    }
}

+(DateTime) lunarFromSolar:(DateTime)solar{
    
    DateTime lunar;
    lunar.Type = DateTimeTypeLunar;
    solar_calendar so=solar_creat_date((int)solar.Year, (int)solar.Month, (int)solar.Day);
    lunar_calendar lu=solar2lunar(so);
    lunar.Year = lunar_get_year(lu);
    lunar.Month = lunar_get_month(lu);
    lunar.Day = lunar_get_day(lu);
    lunar.Hour = solar.Hour;
    lunar.Minute = solar.Minute;
    lunar.Second = solar.Second;
    if (lunar.Month == 100) {
        lunar.isLunarMonthLeap = YES;
        lunar.Month = lunar_leap_month((int)lunar.Year);
    }
    else {
        lunar.isLunarMonthLeap = NO;
    }
    return lunar;
}

/*!
 *  获取日飞星
 *  @param date 日期

 *  @return
 */
+(NSInteger)getFXOfDate:(NSDate *)date{
    int xiaZhiDay = TermTable[date.ylYear-1900][11];//171
    int dongZhiDay = TermTable[date.ylYear - 1900][23];//335
    
    NSString *jiaZiFirstDayStr = @"1900-02-20 00:00:00";
    NSDate *jiaZiFirstDayDate = [NSDate dateFromString:jiaZiFirstDayStr WithFormat:@"yyyy-MM-dd HH:mm:ss"];//1900-02-19 15:54:17 +0000
    
    NSDate  *yearFirstDay = [NSDate dateFromString:[NSString stringWithFormat:@"%i-01-01 00:00:00",date.ylYear] WithFormat:@"yyyy-MM-dd HH:mm:ss"];//当年第一天 1989-12-31 16:00:00 +0000
    
    NSInteger fx = 9;
    
    NSInteger yearToJiaZi = [yearFirstDay hl_daysSinceDate:jiaZiFirstDayDate]; //当年第一天到初始甲子的天数 32822
    NSInteger xiaZhidayCount = yearToJiaZi+xiaZhiDay; //当年夏至到初始甲子的天数 32993
    int mod1 = xiaZhidayCount%60; //夏至到最近甲子日的天数 53
    
    NSDate *xiaZhiDate = [yearFirstDay dateAfterDay:xiaZhiDay]; //当年夏至的日期 1990-06-20 15:00:00 +0000
    NSDate *dongZhiDate = [yearFirstDay dateAfterDay:dongZhiDay];//当年冬至的日期 1990-12-21 16:00:00 +0000
    
    NSDate *xiaZhiJiaZi ;
    if (mod1<30) { //当前节气 距离前一个甲子日近
        xiaZhiJiaZi = [xiaZhiDate dateAfterDay:-mod1]; //距离夏至最近甲子日的日期
    }else{
        xiaZhiJiaZi = [xiaZhiDate dateAfterDay:60-mod1]; //距离夏至最近甲子日的日期  1990-06-27 15:00:00 +0000
    }
    
    NSInteger dongZhiDayCount = yearToJiaZi+dongZhiDay; //当年冬至到初始甲子的天数 33177
    int mod11 = dongZhiDayCount%60; //冬至到最近甲子日的天数 32645
    
    NSDate *dongZhiJiaZi ;
    if (mod11<30) { //当前节气 距离前一个甲子日近
        dongZhiJiaZi = [dongZhiDate dateAfterDay:-mod11]; //距离夏至最近甲子日的日期
    }else{
        dongZhiJiaZi = [dongZhiDate dateAfterDay:60-mod11]; //距离夏至最近甲子日的日期
    }
    
    NSInteger xiaZhiJiaZiTodayCount = labs([xiaZhiJiaZi hl_daysSinceDate:date]);//当前时间 到距离夏至最近的甲子日的天数 75
    NSInteger dongZhiJiaZiTodayCount = labs([dongZhiJiaZi hl_daysSinceDate:date]);//当前时间 到距离夏至最近的甲子日的天数 255
    
    if (xiaZhiJiaZiTodayCount < dongZhiJiaZiTodayCount) {
        
        int result1 = [LTDateTimeTool compareWithDate:date withDate:xiaZhiJiaZi];//判断当前日期与甲子日的前后关系 -1
        
        if (result1 == 0) {  //相等时
            fx = 9;
        }else if(result1 == 1){
            fx =  9 - labs(xiaZhiJiaZiTodayCount %9);
        }else if (result1 == -1){
            fx = 9 -labs((xiaZhiJiaZiTodayCount-1) %9);
        }
        
        return fx;
    }else{
        fx = 1;
        
        int result1 = [LTDateTimeTool compareWithDate:date withDate:dongZhiJiaZi];//判断当前日期与甲子日的前后关系
        
        if (result1 == 0) {  //相等时
            fx = 1;
        }else if(result1 == 1){
            fx = labs(dongZhiJiaZiTodayCount%9+1);
        }else if (result1 == -1){
            fx = labs((dongZhiJiaZiTodayCount-1) %9+1);
        }
        
        return fx;
    }
}
+(NSString *)getFXStrOfIndex:(NSInteger)index{
    NSString *str ;
    switch (index) {
        case 1:
            str = @"一白-贪狼星(水)";
            break;
        case 2:
            str = @"二黑-巨门星(土)";
            break;
        case 3:
            str = @"三碧-禄存星(木)";
            break;
        case 4:
            str = @"四绿-文曲星(木)";
            break;
        case 5:
            str = @"五黄-廉贞星(土)";
            break;
        case 6:
            str = @"六白-武曲星(金)";
            break;
        case 7:
            str = @"七赤-破军星(金)";
            break;
        case 8:
            str = @"八白-左辅星(土)";
            break;
        case 9:
            str = @"九紫-右弼星(火)";
            break;
            
        default:
            break;
    }
    return str;
}
+(NSString *)getFXExplainOfIndex:(NSInteger)index {
    NSString *str;
    switch (index) {
        case 1:
            str = @"吉星，五行属水。一白星在得令的时候，代表官升、名气、中状元、官运和财运。失令的时候，此星为桃花劫，破财损家，甚至性病、绝症，异乡流亡。";
            break;
        case 2:
            str = @"凶星，五行属土。二黑星代表病符。此星在得令的时候并非病符，代表位列尊崇，能成霸业。但此星失令的时候，是一极大凶星，破财损家，代表死亡绝症、破财横祸，与五黄星并列为最凶之星。此星亦代表招来阴灵。";
            break;
        case 3:
            str = @"凶星，五行属木。三碧星代表是非。此星在得令时代表因口材而成名，大利律师、法官急鬼才等职。但此星失令的时候，代表是非官非，破财招刑。";
            break;
        case 4:
            str = @"吉星，五行属木。文曲星在得令的时代表文化艺术、才华、文思敏捷。但失令时为桃花劫星必招酒色之祸。";
            break;
        case 5:
            str = @"凶星，五行属土。廉贞星得令时代表位处中极、威崇无比，如皇帝之最尊最贵。但此星失令的时，称为五黄煞又名正关煞，代表死亡绝症、血光之灾，家破人亡。此星亦必招邪灵之物。";
            break;
        case 6:
            str = @"吉星，五行属金。六白是偏财星，与一白、八白合称三大财星。六白得令时丁财两旺，失令时，为失财星，可令倾家荡产。";
            break;
        case 7:
            str = @"凶星，五行属金。七赤星当运的时候，大利以口才工作的人，包括歌星、演说家、占卜家等，大利通讯传播。但七赤星退运时候，代表口舌是非，刀光剑影，世界大战。又代表火险、及身体上呼吸、肺部的毛病。";
            break;
        case 8:
            str = @"吉星，五行属土。八白星得令时为太白财星，能带来功名富贵。田宅科发，为九星中第一吉星。此星失令的时，为失财失义，瘟疫流行，失财于刹间。";
            break;
        case 9:
            str = @"吉星，五行属火。九紫星当令时为一级喜庆星及爱情星，代表桃花人缘及天乙贵人，大利置业及建筑。但此星失令的时为桃花劫星，损丁破财，亦主火灾、爆炸、心脏病、眼疾、流血等。";
            break;
            
        default:
            break;
    }
    return str;
}

+(NSInteger)getFXOfCurrentSite:(NSInteger)index todayStar:(NSInteger )star{
    switch (index) {
        case 0:
            star += 8;
            break;
        case 1:
            star += 4;
            break;
        case 2:
            star += 6;
            break;
        case 3:
            star += 7;
            break;
        case 4:
            star += 0;
            break;
        case 5:
            star += 2;
            break;
        case 6:
            star += 3;
            break;
        case 7:
            star += 5;
            break;
        case 8:
            star += 1;
            break;
            
        default:
            break;
    }
    star = star % 9;
    if (star == 0) {
        star = 9;
    }
    
    return star;
}

/*****************************************************************************************************/
+(int)getSecondsSinceToNextDay{
    YLDate *now = [YLDate ylDateWithDate:[NSDate date]];
    YLDate *tomorrow = [YLDate ylDateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld 23:59:59",(long)now.ylYear,(long)now.ylMonth,(long)now.ylDay] WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    int times = [tomorrow.date timeIntervalSinceNow];
    return times;
}
@end
