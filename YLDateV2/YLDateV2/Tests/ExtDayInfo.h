//
//  ExtDayInfo.h
//  Calendar
//
//  Created by Jasonluo on 12/20/11.
//  Copyright (c) 2011 YouLoft.Com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "YLDate.h"

typedef enum : NSUInteger {
    CompassUnknown,
    CompassNorth,
    CompassNortheast,
    CompassEast,
    CompassSoutheast,
    CompassSouth,
    CompassSouthwest,
    CompassWest,
    CompassNorthwest
} CompassDirection;

typedef enum :NSUInteger {
    JXStatusUnknown,
    JXStatusJi,
    JXStatusXiong
} JXStatus;

@class ExtDateTime,Lunar;
@interface ExtDayInfo : NSObject {
    sqlite3 *db;
    sqlite3 *huangLidb;//黄历数据库
    NSArray *_conArray;
}

@property (atomic,retain) NSDictionary *festivals;
@property (nonatomic,retain) Lunar *lunarMgr;

/**
 *  @brief 获取值神信息
 *
 *  @param monthDz 月份地支信息
 *  @param dayDz   日期地支信息
 *
 *  @return 值神信息
 */
- (NSString *)zhiShenOfMonth:(NSInteger)monthDz dayIndex:(NSInteger)dayDz;

/**
 *  @brief 获取值神详细信息
 *
 *  @param columnName 数据库字段名
 *  @param content    内容
 *
 *  @return 值神详细信息
 */
-(NSArray*)getZhishenArr:(NSString*)columnName content:(NSString*)content;

/**
 *  @brief 获取建除12神信息
 *
 *  @param date 日期
 *
 *  @return 建除12神信息
 */
- (NSString *)jianChuOfDate:(YLDate *)date;

/**
 *  @brief 获取建除12神详情
 *
 *  @param columnName 数据库字段名
 *  @param content 建除
 *
 *  @return 建除12神详情
 */
-(NSArray*)getJianchuArr:(NSString*)columnName content:(NSString*)content;

/**
 *  @brief 获取二十八星宿信息
 *
 *  @param date 日期
 *
 *  @return 二十八星宿信息
 */
- (NSString *)stars28OfDate:(YLDate *)date;

/**
 *  @brief 获取二十八星宿详情信息
 *
 *  @param columnName 字段名
 *  @param content 星宿
 *
 *  @return 二十八星宿详情信息
 */
-(NSArray*)getStar28Arr:(NSString*)columnName content:(NSString*)content;

/**
 *  @brief 获取胎神方位
 *
 *  @param monthDizhi 月份地支
 *  @param tgdzDay    日天干地支
 *
 *  @return 胎神方位
 */
- (NSString *)taiShenOfMonthDiZhi:(NSString *)monthDizhi dayTgdz:(NSString *)tgdzDay;

/**
 *  @brief 获取胎神详情
 *
 *  @param columnName 胎神字段名
 *  @param content 胎神
 *
 *  @return 胎神详情
 */
-(NSArray*)getTaishenArr:(NSString*)columnName content:(NSString*)content;

- (NSArray *) allSPFestivalData;

-(void) loadFestivals;
-(NSArray*) solarHolidayOfSolar:(ExtDateTime*)solar;
-(NSArray*) lunarHolidayOfLunar:(ExtDateTime*)lunar;
-(NSArray*) weekHolidayOfSolar:(ExtDateTime*)solar;
-(NSDictionary*) briefHuangLiOfSolar:(ExtDateTime*)solar;
-(NSDictionary*) detailHuangLiOfSolar:(ExtDateTime*)solar;
-(NSArray*) briefHuangLiBegin:(ExtDateTime*)begin end:(ExtDateTime*)end keyword:(NSString*)keyword yi:(BOOL)yi;
- (NSArray *) allZejiData;
-(NSString*) constellationOfSolar:(ExtDateTime*)solar;
-(int) constellationIndexOfSolar:(ExtDateTime*)solar;
-(NSString*) constellationStrOfIndex:(int)index;
-(NSString*) constellationDateStrOfIndex:(int)index;
-(NSString *) explainHuangliStr:(NSString *) huangliStr;//hzp

/*!
 
 @method explainHuangliStrRetry:
 
 @abstract 查询黄历项目(如嫁娶，入宅等)的现代文解释
 
 @author: Alan Chen on 2017/2/18
 
 @discussion 由于方法 explainHuangliStr: 存在查询失败的情况，失败的原因是
 sqlite 并不是线程安全的，查询时常常出现 SQLITE_IOERR(10) extended_error(6922),
 所以在查询时如果发现失败，则重新打开数据库再做查询。这个方法只是 workaround solution，
 以后重新设计数据库查询再修改。
 
 1. 貌似并不是多线程引起的。
 2. 不是数据库的意外关闭引起的。
 
 @param huangliStr 黄历项目古代文
 
 @return 黄历项目现代文
 
 */
-(NSString *) explainHuangliStrRetry:(NSString *) huangliStr;

-(NSString*) compassDirectionStringFromEnum:(CompassDirection)direction;
-(NSString*) jixiongStringFromEnum:(JXStatus)status;
-(CompassDirection) caiCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
-(CompassDirection) xiCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
-(CompassDirection) fuCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
-(CompassDirection) nanCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
-(CompassDirection) nvCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;

-(JXStatus) jixiongStatusOfDateTime:(YLDate*)datetime;

-(int) chongIndexOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
-(CompassDirection) shaDirectionOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
/*!
 @abstract 当日地支生肖
 @discussion 通过日期来判断当天属于什么哪一个地支生肖
 @param solar 当日日期
 @param ignoreTime ？
 @result 返回生肖对应的字符串
 */
-(NSString*) zodiacDayOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
/*!
 @abstract 当日生肖地支
 @discussion 通过日期来判断当天属于什么哪一个生肖地支
 @param solar 当日日期
 @param ignoreTime ？
 @result 返回地支对应的字符串
 */
-(NSString*) terrestrialBranchDayOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime;
-(void) reOpenDB;


-(NSMutableArray *) festivalsInfoWithDate:(YLDate *) selectedDate includeWestFes:(BOOL) addWestFes includeBEFes:(BOOL) addBEFes;

+(ExtDayInfo*) extDayInfoManager;
-(void) loadFestivalsWithOutBE;
@end
