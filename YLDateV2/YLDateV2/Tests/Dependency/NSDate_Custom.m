//
//  NSDate_Custom.m
//  Calendar
//
//  Created by Jasonluo on 11-5-13.
//  Copyright 2011 YouLoft.Com. All rights reserved.
//

#import "NSDate_Custom.h"
#import "GLCalendarCenter.h"
#ifndef isLeapYear
#define isLeapYear(x) ((x) % 400 == 0)||((x) % 4 == 0 && (x) % 100 != 0)
#endif

@interface YLDCCache : NSObject
@property (nonatomic,assign) NSObject *object;
@property (nonatomic,retain) NSDateComponents *components;
@end
@implementation YLDCCache
-(void) dealloc {
    [_components release];
    [super dealloc];
}
@end

@implementation NSDate(Custom)

+ (NSDate *)currentDateWithTimeZone:(NSInteger)timeZone {
    NSInteger secondsFromGMT = [NSTimeZone systemTimeZone].secondsFromGMT;
    NSInteger offset = timeZone * 60 * 60 - secondsFromGMT;
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:offset];
    return currentDate;
}

+(NSDate*) ylDateWithYear:(int)year Month:(int)month Day:(int)day Hour:(int)hour Minute:(int)minute Second:(int)second {
    NSDateComponents *cp = [[NSDate date] ylInstantDateComponents];
    [cp setYear:year];
    [cp setMonth:month];
    [cp setDay:day];
    [cp setHour:hour];
    [cp setMinute:minute];
    [cp setSecond:second];
    return [NSDate ylDateFromComponents:cp];
}

+(NSDate*) ylDateFromComponents:(NSDateComponents*)components {
    return [[NSDate ylCalendarManager] dateFromComponents:components];
}
+(NSDate*) ylDateFromString:(NSString*)date WithFormat:(NSString*)format {
	NSDate *Date = nil;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [formatter setCalendar:cal];
    [cal release];
	[formatter setDateFormat:format];
	Date = [formatter dateFromString:date];
	[formatter release];
	return Date;
}
+(NSDate*) ylLocaleDateFromGMT:(NSDate*)gmtDate {
	int iSecondsFromGMT = (int)[[NSTimeZone systemTimeZone] secondsFromGMTForDate:gmtDate];
	return [NSDate dateWithTimeInterval:iSecondsFromGMT sinceDate:gmtDate];
}

+(BOOL) ylIsDaylightSavingTime {
    return [[NSDate ylCalendarManager].timeZone isDaylightSavingTime];
}

static YLDCCache *manager = nil;
+(YLDCCache*) ylCacheManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YLDCCache new];
    });
    return manager;
}
+(NSCalendar*) ylCalendarManager {
    static NSCalendar *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return manager;
    
}

-(NSDateComponents*) ylInstantDateComponents {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dc = [cal components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond|kCFCalendarUnitWeekday|kCFCalendarUnitWeekdayOrdinal|kCFCalendarUnitWeekOfYear fromDate:self];
    [cal release];
    return dc;
}
-(NSDateComponents*) ylDateComponents{
    @synchronized(self){
        NSDateComponents *_ylComponents = nil;
        if ([NSDate ylCacheManager].object == self) {
            _ylComponents = [NSDate ylCacheManager].components;
        }
        if (!_ylComponents) {            
            _ylComponents = [[NSDate ylCalendarManager] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond|kCFCalendarUnitWeekday|
                             kCFCalendarUnitWeekdayOrdinal|kCFCalendarUnitWeekOfYear fromDate:self];
            [NSDate ylCacheManager].object = self;
            [NSDate ylCacheManager].components = _ylComponents;
        }
        return _ylComponents;
    }
}

-(int) ylYear {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp year];
    [cp release];
    return result;
}
-(int) ylMonth {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp month];
    [cp release];
    return result;
}
-(int) ylDay {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp day];
    [cp release];
    return result;
}
-(int) ylHour {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp hour];
    [cp release];
    return result;
}
-(int) ylMinute {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp minute];
    [cp release];
    return result;
}
-(int) ylSecond {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp second];
    [cp release];
    return result;
}
-(int) ylWeekday {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp weekday]-1;
    [cp release];
    return result;
}
-(int) ylWeekdayOrdinal {
    NSDateComponents *cp = [[self ylDateComponents] retain];
    int result = (int)[cp weekdayOrdinal];
    [cp release];
    return result;
}

-(BOOL) ylIsSameDateWithDate:(NSDate*)date {
    NSDateComponents *selfcp = [[self ylDateComponents] retain];
    NSDateComponents *othercp = [[date ylDateComponents] retain];
    BOOL result = NO;
    if ([selfcp year] == [othercp year] && [selfcp month] == [othercp month] && [selfcp day] == [othercp day]) {
        result = YES;
    }
//    
//    if ([self ylYear] == [date ylYear] && [self ylMonth] == [date ylMonth] && [self ylDay] == [date ylDay]) {
//        return YES;
//    }
    [selfcp release];
    [othercp release];
    return result;
}

-(int) ylWeekOfYear {
    int iWeekOfYear = 0;
    NSDateComponents *cp = [[self ylDateComponents] retain];
    if ([cp respondsToSelector:@selector(weekOfYear)]) {
        iWeekOfYear = (int)[cp weekOfYear];
    }
    else {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#pragma clang diagnostic pop
        [outputFormatter setCalendar:cal];
        [outputFormatter setDateFormat:@"ww"];
        iWeekOfYear = [[outputFormatter stringFromDate:self] intValue];
        [outputFormatter release];
        [cal release];
    }
    [cp release];
	return iWeekOfYear;	
}
-(int) ylMaxDayCountsOfThisMonth {
	int arrDaysOfMonth[12] = { 31,isLeapYear([self ylYear])?29:28,31,30,31,30,31,31,30,31,30,31 };
	return arrDaysOfMonth[[self ylMonth]-1];
}
-(int) ylMaxDayCountsOfThisYear {
	return isLeapYear([self ylYear])?366:365;
}
-(NSDate*) ylAddDays:(int)days {
	return [NSDate dateWithTimeInterval:days*24*60*60 sinceDate:self];
}
-(int) ylDaysSinceDate:(NSDate*)anotherDate {
    BOOL betterUse = NO;
    if ([anotherDate ylHour] == [self ylHour] &&
        [anotherDate ylMinute] == [self ylMinute] &&
        [anotherDate ylSecond] == [self ylSecond]) {
        betterUse = YES;
    }
    if (betterUse) {
        return ([self timeIntervalSinceDate:anotherDate]/60/60/24);
    }
    
    NSDateComponents *cp1 = [[anotherDate ylDateComponents] retain];
    cp1.hour = 0;
    cp1.minute = 0;
    cp1.second = 0;
    
    NSDateComponents *cp2 = [[self ylDateComponents] retain];
    cp2.hour = 0;
    cp2.minute = 0;
    cp2.second = 0;
    
    NSTimeInterval time = [[NSDate ylDateFromComponents:cp2] timeIntervalSinceDate:[NSDate ylDateFromComponents:cp1]];
    [cp1 release];
    [cp2 release];
	return (time/60/60/24);
}

-(int) ylChineseNumHour {
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
/**
*  传入时间字符串，返回日期对象
*
*  @param date   日期字符串
*  @param format 日期格式
*
*  @return 日期对象
*/
+(NSDate*) dateFromString:(NSString*)date WithFormat:(NSString*)format {
    
    if ([date isKindOfClass:[NSNull class]]||date==nil) {
        return nil;
    }
    NSDate *Date = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [formatter setTimeZone:GTMzone];
    if(![GLCalendarCenter sharedInstance].isStandardCalendar){
        NSCalendar* calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
        formatter.calendar = calendar;
    }
    [formatter setDateFormat:format];
    Date = [formatter dateFromString:date];
    [formatter release];
    return Date;
}
/**
 *  两个日期之间相差的天数
 */
-(int) hl_daysSinceDate:(NSDate*)anotherDate {
    
    NSString *newDateStrSelf = [[self stringWithFormat:@"yyyy-MM-dd"] stringByAppendingString:@" 00:00:00"];
    NSString *anotherDateStrSelf = [[anotherDate stringWithFormat:@"yyyy-MM-dd"] stringByAppendingString:@" 00:00:00"];
    NSDate* newDateSelf = [NSDate dateFromStringRewrite:newDateStrSelf WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* newAnotherDateSelf = [NSDate dateFromStringRewrite:anotherDateStrSelf WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval time = [newDateSelf timeIntervalSinceDate:newAnotherDateSelf];
    return (time/60/60/24);
}
+(NSDate*) dateFromStringRewrite:(NSString*)date WithFormat:(NSString*)format {
    
    if ([date isKindOfClass:[NSNull class]]||date==nil) {
        return nil;
    }
    NSDate *Date = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [formatter setTimeZone:GTMzone];
    if(![GLCalendarCenter sharedInstance].isStandardCalendar){
        NSCalendar* calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
        formatter.calendar = calendar;
    }
    [formatter setDateFormat:format];
    Date = [formatter dateFromString:date];
    [formatter release];
    return Date;
}

/**
 *  传入格式，返回日期的字符串描述(返回当前时区的描述)
 */
- (NSString *)stringWithFormat:(NSString *)format {
    @try {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        if(![GLCalendarCenter sharedInstance].isStandardCalendar){
            NSCalendar* calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
            outputFormatter.calendar = calendar;
        }
        [outputFormatter setDateFormat:format];
        NSString *timestamp_str = [outputFormatter stringFromDate:self];
        [outputFormatter release];
        return timestamp_str;
    }
    @catch (NSException *exception) {
        return nil;
    }
}
/**
 *  增加天数
 *
 *  @param days 天数增量
 *
 *  @return 新日期
 */
-(NSDate*) addDays:(int)days {
    return [NSDate dateWithTimeInterval:days*24*60*60 sinceDate:self];
}
//返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterDay:(NSInteger)day
{
    NSCalendar *calendar = [GLCalendarCenter sharedInstance].gelonCalendar;
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:day];
    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return dateAfterDay;
}
@end
