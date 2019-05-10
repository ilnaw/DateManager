/*!
 @header YLDate.h
 @abstract 日期类工具
 @author Created by HuangZhenPeng.
 @version 4.5.4 2014/2/18 Creation
 Copyright © 2014年 YouLoft. All rights reserved.
 */

#import <Foundation/Foundation.h>

#define kYLDateBEOffset 544 // 543

/*!
 @class YLDate
 @abstract 日历转换工具
 @discussion 可用于日历的各种转换
*/
@interface YLDate : NSObject {
    /*!
     @discussion 日期
     */
    NSDate *_date;
    /*!
     @discussion components日期组件
     */
    NSDateComponents *_components;
}
/*!
 @typedef DateTimeType
 @abstract 时间类型
 @discussion 时间的类型（阳历、农历）
 @field  DateTimeTypeSolar 阳历
 @field  DateTimeTypeSolar 阴历（农历）
 */
typedef enum{
    DateTimeTypeSolar,//阳历
    DateTimeTypeLunar//农历
}DateTimeType;
/*!
 @typedef DateTime
 @abstract DateTime结构包含日期类型、年、月、日、时、分、秒、是否闰月
 @discussion
 @field Type 阳历还是农历？
 @field Year 年
 @field Month 月
 @field Day 日
 @field Hour 时
 @field Minute 分
 @field Second 秒
 @field isLunarMonthLeap 是否闰月
 */
typedef struct {
    DateTimeType Type;//阳历还是农历
    NSInteger Year;
    NSInteger Month;
    NSInteger Day;
    NSInteger Hour;
    NSInteger Minute;
    NSInteger Second;
    BOOL isLunarMonthLeap;//该月是否是闰月(只针对农历)
    
}DateTime;
/*!
 @discussion 是否闰年
 */
@property (nonatomic, readonly) BOOL isLeapYear;
/*!
 @discussion 日期
 */
@property (nonatomic, strong,readonly) NSDate *date;
/*!
 @discussion components日期组件
 */
@property (nonatomic, strong,readonly) NSDateComponents *components;

/*!
 @abstract YLDate date转换类方法
 @discussion 将NSDate转换成YLDate日期。
 @param date 日期
 @result ylDate
 */
+(YLDate *) ylDateWithDate:(NSDate *)date;

/*!
 @abstract 年、月、日、时、分、秒转化为YLDate 日期
 @discussion 通过传入具体的年、月、日、时、分、秒转换components日期组件再转为对应的日期。
 @param year   年
 @param month  月
 @param day    日
 @param hour   时
 @param minute 分
 @param second 秒
 @result (YLDate)日期
 */
+(YLDate *) ylDateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day Hour:(NSInteger)hour Minute:(NSInteger)minute Second:(NSInteger)second;

/*!
 @abstract 日期组件转换为日期
 @discussion 将传入的日期组件转换为对应的日期。
 @param components 日期组件
 @result (YLDate)日期
 */
+(YLDate *) ylDateFromComponents:(NSDateComponents*)components;
/*!
 @abstract 日期字符串转换为日期
 @discussion 根据传入的日期字符串、日期格式字符串转换为对应的日期。
 @param date 日期字符串
 @param format 日期格式字符串
 @result (YLDate)日期
 */
+(YLDate *) ylDateFromString:(NSString*)date WithFormat:(NSString*)format;

/*!
 @abstract 日期换算
 @discussion 根据GMT标准时间与系统本地时区的时差，来计算系统日期。
 @param gmtDate 日期
 @result 本地日期
 */
+(YLDate *) ylLocaleDateFromGMT:(YLDate *)gmtDate;

/*!
 @abstract 是否在夏令制时区
 @discussion 指示指定的日期和时间是否处于当前 TimeZoneInfo 对象时区的夏令制范围内。
 @result YES/NO
 */
+(BOOL) ylIsDaylightSavingTime;

/*!
 @abstract 日期管理工具类方法
 @discussion 这是YLDate的单例方法。
 @result 日期单例
 */
+(NSCalendar*) ylCalendarManager;

/*!
 @abstract 复活节
 @discussion 根据给定的年份计算出该年份的复活节日期。
 @param year 年份
 @result 给定年的复活节日期
 */
+(YLDate *) ylEasterDayOfYear:(NSInteger) year;
/*!
 @abstract 佛历
 @discussion 根据给定的日期换算出该日期对应的佛历。
 @param date 日期
 @result 坲历
 */
+(NSInteger) ylBEYearWithDate:(YLDate *) date;
/*!
 @abstract 获取年飞星 hyd 4.5.4
 @discussion 通过日期来换算对应的年飞星。
 @param date 日期
 @result 年飞星索引
 */
+(NSInteger)getYearFXOfDate:(YLDate *)date;
/*!
 @abstract 获取月飞星
 @discussion 通过日期来换算对应的月飞星。
 @param date 日期
 @result 月飞星索引
 */
+(NSInteger)getMonthFXOfDate:(NSDate *)date;
/*!
 @abstract 获取日飞星
 @discussion 通过日期来换算对应的年日飞星。
 @param date 日期
 @result 日飞星索引
 */
+(NSInteger)getFXOfDate:(NSDate *)date;
/*!
 @abstract 飞星title
 @discussion 通过索获取对应的飞星。
 @param index 索引
 @result 返回对应的飞星title
 */
+(NSString *)getFXStrOfIndex:(NSInteger)index;
/*!
 @abstract  飞星每个宫格数据
 @discussion 通过每个宫格的位置以及对应的飞星 获取该宫格的年、月、日飞星对应的数字。
 @param index 宫格的位置
 @param star  飞星
 @result 飞星对应的数字
 */
+(NSInteger)getFXOfCurrentSite:(NSInteger)index todayStar:(NSInteger )star;

/*!
 @abstract 初始化阳历date
 @discussion 通过传入的阳历初始化为datetime。
 @param solarNSDate 阳历日期
 @result DateTime
 */
+(DateTime)initDateTimeWithNSDate:(NSDate *)solarNSDate;

/*!
 @abstract 阴历月
 @discussion 阳历日期换算为对应的阴历月。
 @param dt DateTime日期
 @result 阴历月
 */
+(NSString*) lunarMonthString:(DateTime)dt;
/*!
 @abstract 飞星解释
 @discussion 通过索引获取飞星对应的解释内容。
 @param index 索引
 @result 返回对应飞星的解释
 */
+(NSString *)getFXExplainOfIndex:(NSInteger)index;
/*!
 @abstract _components日期组件赋值
 @discussion 给_components组件赋值
 @result _components
 */
-(NSDateComponents*) ylDateComponents;

/*!
 @abstract 年份
 @discussion 获取components年。
 @result 年
 */
-(NSInteger) ylYear;
/*!
 @abstract 月份
 @discussion 获取components月。
 @result 月
 */
-(NSInteger) ylMonth;
/*!
 @abstract 日
 @discussion 获取components日。
 @result 日
 */
-(NSInteger) ylDay;
/*!
 @abstract 小时
 @discussion 获取components小时。
 @result 小时
 */
-(NSInteger) ylHour;
/*!
 @abstract 分钟
 @discussion 获取components分钟。
 @result 分钟
 */
-(NSInteger) ylMinute;
/*!
 @abstract 秒
 @discussion 获取components秒。
 @result 秒
 */
-(NSInteger) ylSecond;
/*!
 @abstract  星期几
 @discussion 获取components星期几。
 @result 星期几
 */
-(NSInteger) ylWeekday;
/*!
 @abstract  当月第几周
 @discussion 获取components当月第几周。
 @result 当月第几周
 */
-(NSInteger) ylWeekdayOrdinal;
/*!
 @abstract  当年第几周
 @discussion 获取components当年第几周。
 @result 当年第几周
 */
-(NSInteger) ylWeekOfYear;
/*!
 @abstract  当月最大天数
 @discussion 获取components当月最大天数。
 @result 当月最大天数
 */
-(NSInteger) ylMaxDayCountsOfThisMonth;
/*!
 @abstract  当年最大天数
 @discussion 获取components当年最大天数。
 @result 当年最大天数
 */
-(NSInteger) ylMaxDayCountsOfThisYear;
/*!
 @abstract  增加天数
 @discussion 获取增加天数后的日期。
 @param days 增加的天数
 @result 添加天数后的日期
 */
-(YLDate *) ylAddDays:(NSInteger)days;

/*!
 @abstract 计算若干个月后的日期
 @discussion 计算若干个月后的日期
 @param months 若干月的数量
 @return 若干个月后的日期
 */
- (YLDate *) ylAddMonths: (NSInteger) months;
/*!
 @abstract 给定日期距离今天的天数
 @discussion 计算出给定日期距离今天相隔的天数
 @param anotherDate 另外一个日期
 @return 相隔的天数
 */
-(NSInteger) ylDaysSinceDate:(YLDate *)anotherDate;
/*!
 @abstract 时辰换算
 @discussion 换算阳历hour对应的时辰
 @return 时辰
 */
-(NSInteger) ylChineseNumHour;
/*!
 @abstract 是否同一天
 @discussion 比较传入日期的年、月、日判断是否为同一天
 @param date 日期
 @return YES/NO
 */
-(BOOL) ylIsSameDateWithDate:(YLDate *)date;

/*!
 @abstract 初始化components日期组件
 @discussion 通过日期初始化一个components日期组件。
 @result components日期组件
 */
-(NSDateComponents*) ylInstantDateComponents;
/*!
 @abstract 该月第一天
 @discussion 获取该月第一天的日期
 @return 第一天的日期
 */
-(YLDate *) firstDayInMonth;

/*!
 @abstract 是否周末
 @discussion 判断所选日期是否为周末。
 @result YES/NO
 */
-(BOOL) isWeekend;

/*!
 @discussion 判断所选日期是否为今天。
 */
@property (nonatomic, readonly) BOOL isToDay;
/*!
 @discussion 判断所选日期是否为明天。
 */
@property (nonatomic, readonly) BOOL isNextDay;
/*!
 @discussion 判断所选日期是否为后天。
 */
@property (nonatomic, readonly) BOOL isTheDayAfterTomorrow;
/*!
 @discussion 判断所选日期是否为大后天。
 */
@property (nonatomic, readonly) BOOL isTheThirdDay;
/*!
 @discussion 判断所选日期是否为昨天。
 */
@property (nonatomic, readonly) BOOL isYesterday;
/*!
 @discussion 判断所选日期是否为前天。
 */
@property (nonatomic, readonly) BOOL isTheDayBeforeYesterday;

/*!
 @abstract 周开始、结束日期
 @discussion 换算选择日期所在周的起始日期和结束日期。
 @result 以字符串形式返回所在周的起始日期和结束日期
 */
- (NSString *)retCurrentWeekDays;

/**
 显现在开始到明天凌晨零点秒数

 @return 返回的秒数
 */
+(int)getSecondsSinceToNextDay;
@end
