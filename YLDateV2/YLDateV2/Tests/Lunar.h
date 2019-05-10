/*!
 @header Lunar.h
 @abstract 日历换算
 @author Created by Jasonluo.
 @version  2012/8/11 Creation
 Copyright © 2012 YouLoft.com. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "YLDate.h"

#ifndef LEAP
#define LEAP(year) ( (((year)%400 == 0) || ((year)%4 == 0 && (year)%100 != 0)) ? 1:0 )
#endif
#ifndef ABS
#define ABS(num) ( (num) < 0 ? (-(num)):(num) )
#endif
/*!
 @typedef StemAndBranch
 @abstract StemAndBranch结构体
 @discussion 生肖索引、年、月、日
 @field AnimalIndex 生肖索引
 @field Year  年
 @field Month 月
 @field Day   日
 */
typedef struct StemAndBranch {
    int AnimalIndex;
    int Year;
    int Month;
    int Day;
} StemAndBranch;
/*!
 @class
 @discussion 引入ExtDateTime类。
 */
@class ExtDateTime;
@interface Lunar : NSObject {
}
/*!
 @discussion 二十四节气数组
 */
@property (nonatomic,retain) NSArray *TermStrArray;
/*!
 @discussion 天干数组
 */
@property (nonatomic,retain) NSArray *StemStrArray;
/*!
 @discussion 地支数组
 */
@property (nonatomic,retain) NSArray *BranchStrArray;
/*!
 @discussion 农历月份数组
 */
@property (nonatomic,retain) NSArray *MonthStrArray;
/*!
 @discussion 农历日数组
 */
@property (nonatomic,retain) NSArray *DayStrArray;
/*!
 @discussion 生肖数组
 */
@property (nonatomic,retain) NSArray *AnimalArray;
/*!
 @abstract 农历转换
 @discussion 所有需要公历转化为农历的地方都可以使用该方法
 @param solar 公历日期
 @result 返回对应的农历
 */
-(ExtDateTime*)lunarFromSolar:(ExtDateTime*)solar;
/*!
 @abstract 公历转换
 @discussion 所有需要农历转化为公历的地方都可以使用该方法
 @param lunar 农历日期
 @result 返回对应的公历
 */
-(ExtDateTime*)solarFromLunar:(ExtDateTime*)lunar;
/*!
 @abstract 公历字符串
 @discussion 公历日期转化为公历字符串可以使用该方法
 @param lunar 公历日期
 @result 公历日期字符串
 */
-(NSString*) lunarStrFromLunar:(ExtDateTime*)lunar;
/*!
 @abstract 月份字符串
 @discussion 月份转化为对应的月份字符串
 @param numMonth 月份
 @result 月份字符串
 */
-(NSString*) lunarStrOfNumMonth:(NSInteger)numMonth;
/*!
 @abstract 日字符串
 @discussion 日转化为对应的日字符串
 @param numDay 日
 @result 日字符串
 */
-(NSString*) lunarStrOfNumDay:(NSInteger)numDay;
/*!
 @abstract 日期对应的二十四节气
 @discussion 给定日期转化为对应的二十四节气
 @param date 日期
 @result 二十四节气index
 */
-(NSInteger) termIndexOfDate:(ExtDateTime*)date;
/*!
 @abstract 二十四节气对应的日期
 @discussion 给定某一年某一个节气换算对应的日期
 @param index 给定某一个节气
 @param year  给定某一年
 @result 节气对应的日期
 */
-(ExtDateTime*) termTimeOfIndex:(NSInteger)index inYear:(NSInteger)year;
/*!
 @abstract 节气
 @discussion 给定index，找到对应的某个二十四节气
 @param index 节气索引
 @result 节气字符串
 */
-(NSString*) termStrOfIndex:(NSInteger)index;
/*!
 @abstract 前一个节气index
 @discussion 给定日期，计算对应节气的前一个节气？
 @param date 日期
 @result 节气index
 */
-(NSInteger) termIndexBeforeDate:(ExtDateTime*)date;
/*!
 @abstract 二十四节气对应的日期
 @discussion 给定某一年某一个节气换算对应的日期
 @param termIndex 给定某一个节气
 @param year  给定某一年
 @result 节气对应的日期
 */
-(ExtDateTime*)dateOfTerm:(NSInteger)termIndex inYear:(NSInteger)year;
/*!
 @abstract 天干地支字符串
 @discussion 给定index换算对应的天干地支字符串
 @param index 索引
 @result 天干地支字符串
 */
-(NSString*) stemBranchStrOfIndex:(NSInteger)index;
/*!
 @abstract 天干地支
 @discussion 给定日期换算对应的天干地支index
 @param solar 日期
 @result 天干地支index
 */
-(NSInteger) stemBranchYearOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 通过日期 返回生肖数组中的index
 @discussion 用在通过日期来判断生肖属性
 @param solar 选择的日期
 @result 返回生肖index
 */
-(NSInteger) animalIndexOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 生肖属性
 @discussion 用在通过日期来判断生肖属性
 @param index 生肖数组的下标
 @result 返回某一个生肖
 */
-(NSString*) animalStrOfIndex:(NSInteger)index;
/*!
 @abstract 生肖属性
 @discussion 用在通过日期来获取生肖
 @param solar 选择的日期
 @result 返回生肖
 */
-(NSString*) animalStrOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 天干地支月
 @discussion 给定日期换算对应的天干地支月
 @param solar 日期
 @result 天干地支月
 */
-(NSInteger) stemBranchMonthOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 天干地支日
 @discussion 给定日期换算对应的天干地支日
 @param solar 日期
 @result 天干地支日
 */
-(NSInteger) stemBranchDayOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 天干地支时
 @discussion 给定日期换算对应的天干地支时
 @param solar 日期
 @result 天干地支时
 */
-(NSInteger) stemBranchHourOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 天干日
 @discussion 给定日期换算对应的天干日
 @param solar 日期
 @result 天干地支日
 */
-(NSInteger) stemDayOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 地支如
 @discussion 给定日期换算对应的地支日
 @param solar 日期
 @result 地支日
 */
-(NSInteger) branchDayOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 天干地支枚举值
 @discussion 给定日期换算对应的天干地支枚举值
 @param solar 日期
 @result 天干地支枚举值
 */
-(StemAndBranch)stemBranchOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 天干地支生肖字符串
 @discussion 给定日期换算对应的天干地支生肖字符串
 @param solar 日期
 @result 天干地支生肖字符串
 */
-(NSString*) stemBranchStrOfSolarDate:(ExtDateTime*)solar;
/*!
 @abstract 三伏天数组
 @discussion 给定年换算对应的三伏天
 @param year 年
 @result 三伏天数组
 */
-(NSArray*) hotDurationsOfSolarYear:(NSInteger)year;
/*!
 @abstract 某伏某天字符串
 @discussion 给定日期在三伏天中查找对应的某伏某天
 @param date 日期
 @param hotDays 三伏天数组
 @result 某伏某天字符串
 */
-(NSString*) hotDayStrOfDate:(YLDate *)date hotDays:(NSArray*)hotDays;
- (NSString *)hotDayStrOfDate:(YLDate *)date
                      hotDays:(NSArray *)hotDays
                        index:(NSInteger *)index;
/*!
 @abstract 几九开始日期（每年最冷天的起始日）
 @discussion 给定年换算出对应几久开始的日期
 @param year 年
 @result 几九开始日期
 */
-(YLDate *) coldBeginDateOfSolarYear:(NSInteger)year;
/*!
 @abstract 几九字符串
 @discussion 给定日期以及几九开始日期（每年最冷天的起始日）换算对应的几九字符串
 @param date 日期
 @param coldBegin 几九开始日期（每年最冷天的起始日）
 @result 几久字符串
 */
-(NSString*) coldDayStrOfDate:(YLDate *)date coldBeginDate:(YLDate *)coldBegin;
- (NSString *)coldDayStrOfDate:(YLDate *)date
                 coldBeginDate:(YLDate *)coldBegin
                         index:(NSInteger *)index/** 数九第x天(如果不是，则返回-1) */;
/*!
 @abstract 时地支
 @discussion 给定index换算对应的时地支
 @param index 索引对应的小时数
 @result 时地支字符串
 */
-(NSString*) lunarHourStr:(NSInteger)index;
/*!
 @abstract 时辰对应时间段
 @discussion 给定index（时辰）换算对应的时间段
 @param index 时辰索引
 @result 某个时辰对应的时间段
 */
-(NSString*) chineseHourRangeStr:(NSInteger)index;

//-(NSString*) eclipticOfSolar:(ExtDateTime*)solar;
/*!
 @abstract 某年某月最大天数
 @discussion 给定月、年、是否闰月换算出对应月的最大天数
 @param month 月
 @param year  年
 @param isleap 是否闰年
 @result 某年某月最大天数
 */
-(NSInteger) lunarMaxDayOfMonth:(NSInteger)month inYear:(NSInteger)year isLeap:(BOOL)isleap;
/*!
 @abstract 闰几月
 @discussion 给定年换算该年闰几月
 @param year 年
 @result 闰月对应数字
 */
-(NSInteger) lunarLeapMonthOfYear:(NSInteger)year;
@end
