//
//  LTDateTimeTool.h
//  CenterWeather
//
//  Created by NineTonTech on 14-4-16.
//  Copyright (c) 2014年 ninetontech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLDate.h"
#import "NSDate_Custom.h"

@interface LTDateTimeTool : NSObject

//通过文字获取星期的索引（1开始,表示星期日）eg：星期三 返回4；
+(int) getWeekIndexByWeekStr:(NSString *) weekStr;

//根据weekday编号  获取week  mode为0  周一  mode为1  星期一
+(NSString *) getWeekStrByWeekIndex:(int) weekIndex Mode:(int)mode;

//是白天还是黑夜早上6点到晚上7点为白天，返回yes
+(BOOL) isDayTime;

//返回当前的小时（24小时制）
+(NSInteger) currentHour;

//获取时间数组，年，月，日，时，分，秒
+(NSArray *)getCurrentTimeArray;

//星期几
+(NSInteger) currentWeekDay;

//对比两个时间的大小
+(int)compareDate:(NSString*)date01 withDate:(NSString*)date02;

+(int)compareWithDate:(NSDate*)date01 withDate:(NSDate*)date02;


//对比两个时间的差  mode0：10月23日 12点32分  mode1：2014-3-34 8:13:43
+(dateInterval)getIntervalOfDate:(NSString *)date1 date:(NSString *)date2 ofMode:(DateFormate)dateFormate;

//两个时间是否是同一天
+(BOOL)ifTheSameDayOfDate1:(NSDate *)date1 date2:(NSDate *)date2;


@end
