//
//  ExtDateTime.h
//  Calendar
//
//  Created by Jasonluo on 12/9/11.
//  Copyright (c) 2011 YouLoft.Com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLDate.h"

#ifndef LEAP
#define LEAP(year) ( (((year)%400 == 0) || ((year)%4 == 0 && (year)%100 != 0)) ? 1:0 )
#endif

@class Lunar;
@interface ExtDateTime : NSObject <NSCopying> {
}

@property (nonatomic,assign) NSInteger Year;
@property (nonatomic,assign) NSInteger Month;
@property (nonatomic,assign) NSInteger Day;
@property (nonatomic,assign) NSInteger Hour;
@property (nonatomic,assign) NSInteger Minute;
@property (nonatomic,assign) NSInteger Second;
@property (nonatomic,assign) BOOL IsLunar;
@property (nonatomic,assign) BOOL IsLeap;
@property (nonatomic,assign) BOOL IsAllDay;

@property (nonatomic,retain) Lunar *lunarMgr;

+(ExtDateTime*) dateTimeWithNSDate:(YLDate *)date;
+(ExtDateTime*) dateOfYear:(NSInteger)year ByOffset:(NSInteger)offset;
+(ExtDateTime*) dateTimeWithNumDate:(NSInteger)numDate numTime:(NSInteger)numTime;

-(NSInteger) numDate;
-(NSInteger) numTime;
-(NSInteger) solarDayOffset;
-(NSInteger) solarDayCountInMonth;
-(NSInteger) solarDayCountInYear;
-(NSInteger) solarDayIntervalSinceDate:(ExtDateTime*)date;
-(NSString*) solarStr;
-(YLDate *) nsDateValue;
-(BOOL) isLaterThanDate:(ExtDateTime*)date;
-(BOOL) isSameDateWithDate:(ExtDateTime*)date;
-(NSString*) descOfDateTime;


@end
