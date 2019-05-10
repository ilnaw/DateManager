//
//  YLDateV2Tests.m
//  YLDateV2Tests
//
//  Created by zwh on 2019/4/24.
//  Copyright © 2019 zwh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExtDayInfo.h"
#import "Lunar.h"
#import "ExtDateTime.h"
#import "YLSAADB.h"
#import "YLHuangliDetailDB.h"
#import "YLDateV2.h"

@interface YLDateV2Tests : XCTestCase

@end

@implementation YLDateV2Tests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

// 测试新历属性(年月日等)
- (void)testSolar {
    __weak typeof(self) self_weak_ = self;
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        [self_weak_ _testSolar:date
                            v2:v2];
    }];
}

// 测试星座(名称、下标、日期范围等)
- (void)testConstellation {
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        int idx = [dayInfo constellationIndexOfSolar:solar];
        XCTAssertEqual(idx, v2.solar.constellation.idx, @"星座下标错误! %@", date);
        NSString *s1 = [dayInfo constellationStrOfIndex:idx], *s2 = v2.solar.constellation;
        XCTAssertTrue([s1 isEqualToString:s2], @"星座名称错误! %@", date);
        s1 = [dayInfo constellationDateStrOfIndex:idx];
        s2 = YLSolar.constellationDateRanges[idx % 12];
        XCTAssertTrue([s1 isEqualToString:s2], @"星座日期范围错误! %@", date);
    }];
}

// 测试通过农历初始化DateV2
- (void)testV2FromLunar {
    __weak typeof(self) self_weak_ = self;
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        YLDateComponents *cp = YLDateComponents.new;
        cp.lunar     = YES;
        cp.year      = lunar.Year;
        cp.month     = lunar.Month;
        cp.leapMonth = lunar.IsLeap;
        cp.day       = lunar.Day;
        cp.hour      = lunar.Hour;
        cp.minute    = lunar.Minute;
        cp.second    = lunar.Second;
        
        YLDateV2 *dateV2 = [YLDateV2 dateFromDateComponents:cp];
        // 校验转换后是否正确
        [self_weak_ _testSolar:date
                            v2:dateV2];
    }];
}

// 测试天干地支
- (void)testStemAndBranch {
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        StemAndBranch sb = [lunarMgr stemBranchOfSolarDate:solar];
        NSString *s1 = [lunarMgr lunarHourStr:sb.Year % 12], *s2 = v2.almanac.year.branch;
        XCTAssertTrue([s1 isEqualToString:s2], @"年地支错误! %@", date);
        s1 = [lunarMgr lunarStrOfNumMonth:lunar.Month];
        s2 = v2.lunar.month;
        XCTAssertTrue([s1 isEqualToString:s2], @"农历月错误! %@", date);
        XCTAssertEqual(lunar.IsLeap, v2.lunar.isLeapMonth, @"是否闰月错误！%@", date);
        s1 = [lunarMgr lunarStrOfNumDay:lunar.Day];
        s2 = v2.lunar.day;
        XCTAssertTrue([s1 isEqualToString:s2], @"农历日错误! %@", date);
        XCTAssertEqual(date.ylChineseNumHour, v2.almanac.hour.branch.idx, @"农历时错误! %@", date);
        s1 = [lunarMgr animalStrOfSolarDate:solar];
        s2 = v2.lunar.animal;
        XCTAssertTrue([s1 isEqualToString:s2], @"生肖错误! %@", date);
        NSInteger termIndex = [lunarMgr termIndexOfDate:solar];
        if (termIndex > -1) {
            XCTAssertNotNil(v2.almanac.term, @"节气错误！Lunar有节气，而dateV2没有! %@", date);
            s1 = [lunarMgr termStrOfIndex:termIndex];
            s2 = v2.almanac.term;
            XCTAssertTrue([s1 isEqualToString:s2], @"节气名错误! %@: %@, %@", date, s1, s2);
        } else {
            XCTAssertNil(v2.almanac.term, @"节气错误！Lunar没有节气，而dateV2有! %@", date);
        }
        s1 = [lunarMgr stemBranchStrOfIndex:sb.Year];
        s2 = v2.almanac.year.description;
        XCTAssertTrue([s1 isEqualToString:s2], @"天支年错误! %@", date);
        s1 = [lunarMgr stemBranchStrOfIndex:sb.Month];
        s2 = v2.almanac.month.description;
        XCTAssertTrue([s1 isEqualToString:s2], @"天支月错误! %@", date);
        s1 = [lunarMgr stemBranchStrOfIndex:sb.Day];
        s2 = v2.almanac.day.description;
        XCTAssertTrue([s1 isEqualToString:s2], @"天支日错误! %@", date);
        s1 = [lunarMgr stemBranchStrOfIndex:[lunarMgr stemBranchHourOfSolarDate:solar]];
        s2 = v2.almanac.hour.description;
        XCTAssertTrue([s1 isEqualToString:s2], @"天支时错误! %@", date);
    }];
}

// 测试值神
- (void)testZhishen {
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        StemAndBranch sb = [lunarMgr stemBranchOfSolarDate:solar];
        NSString *s1 = [dayInfo zhiShenOfMonth:sb.Month % 12 dayIndex:sb.Day % 12];
        NSString *s2 = v2.almanac.zhiShen;
        XCTAssertTrue([s1 isEqualToString:s2], @"datev2: --- 值神错误！%@", date);
    }];
}

// 测试28星宿
- (void)testStar {
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        NSString *s1 = [dayInfo stars28OfDate:date];
        NSString *s2 = v2.almanac.star;
        XCTAssertTrue([s1 isEqualToString:s2], @"datev2: --- 星宿错误！%@  %@ -- %@", date, s1, s2);
    }];
}

// 测试胎神
- (void)testFetus {
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        StemAndBranch sb = [lunarMgr stemBranchOfSolarDate:solar];
        // 胎神的查询比较耗时。仅胎神的完整测试跑下来，花了将近两分半钟
        NSString *s1 = [dayInfo taiShenOfMonthDiZhi:lunarMgr.BranchStrArray[sb.Month % 12]
                                            dayTgdz:[lunarMgr stemBranchStrOfIndex:sb.Day]];
        NSString *s2 = v2.almanac.fetus;
        XCTAssertTrue([s1 isEqualToString:s2], @"datev2: --- 胎神错误！%@ %@ --- %@", date, s1, s2);
    }];
}

// 测试黄历简介
- (void)testHuangliBrief {
    NSString *(^shaStr)(CompassDirection direction) = ^NSString *(CompassDirection direction) {
        NSString *lString = [ExtDayInfo.extDayInfoManager compassDirectionStringFromEnum:direction];
        if ([lString rangeOfString:@"正"].location != NSNotFound) {
            return [lString stringByReplacingOccurrencesOfString:@"正"
                                                      withString:@""];
        }
        return lString;
    };
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        NSDictionary *brief = [dayInfo briefHuangLiOfSolar:solar];
        NSString *pzbj      = brief[@"PZBJ"]; // 彭祖百忌
        NSString *wx        = brief[@"WX"]; // 五行
        NSString *jsyq      = brief[@"JSYQ"]; // 吉神宜趋
        NSString *xsyj      = brief[@"XSYJ"]; // 凶神宜忌
        NSString *y         = brief[@"Y"]; // 宜
        NSString *j         = brief[@"Ji"]; // 忌
        NSString *test = v2.almanac.pengZuBaiJi;
        XCTAssertTrue([pzbj isEqualToString:test], @"datev2: --- 彭祖百忌错误! %@ - %@ %@", pzbj, test, date);
        test = v2.almanac.the5Element;
        XCTAssertTrue([wx isEqualToString:test], @"datev2: --- 五行错误! %@ - %@ %@", wx, test, date);
        test = v2.almanac.xiongJiShen.yi;
        if (jsyq.length > 0 && test.length > 0) {
            XCTAssertTrue([jsyq isEqualToString:test], @"datev2: --- 吉神宜趋错误! %@ - %@ %@", jsyq, test, date);
        }
        test = v2.almanac.xiongJiShen.ji;
        if (xsyj.length > 0 && test.length > 0) {
            XCTAssertTrue([xsyj isEqualToString:test], @"datev2: --- 凶神宜忌错误! %@ - %@ %@", xsyj, test, date);
        }
        test = v2.almanac.yiJi.yi;
        if (y.length > 0 && test.length > 0) {
            XCTAssertTrue([y isEqualToString:test], @"datev2: --- 宜错误! %@ - %@ %@", y, test, date);
        }
        test = v2.almanac.yiJi.ji;
        if (j.length > 0 && test.length > 0) {
            XCTAssertTrue([j isEqualToString:test], @"datev2: --- 忌错误! %@ - %@ %@", j, test, date);
        }
        
        // 当日的地支生肖，以及地支
        NSString *dayAnimal = [dayInfo zodiacDayOfDateTime:solar ignoreTime:YES];
        NSString *dayBranch = [dayInfo terrestrialBranchDayOfDateTime:solar ignoreTime:YES];
        test = YLLunar.animals[v2.almanac.day.branch.idx];
        XCTAssertTrue([dayAnimal isEqualToString:test], @"datev2: --- 当日生肖错误! %@ - %@ %@", dayAnimal, test, date);
        test = v2.almanac.day.branch;
        XCTAssertTrue([dayBranch isEqualToString:test], @"datev2: --- 当日生肖地支错误! %@ - %@ %@", dayBranch, test, date);
        
        // 冲煞
        NSInteger chong = [ExtDayInfo.extDayInfoManager chongIndexOfDateTime:solar ignoreTime:YES];
        CompassDirection sha = [ExtDayInfo.extDayInfoManager shaDirectionOfDateTime:solar ignoreTime:YES];
        XCTAssertEqual(chong, v2.almanac.chong.idx, @"datev2: --- 冲下标错误! %@ - %@ %@", @(chong), @(v2.almanac.chong.idx), date);
        XCTAssertEqual(sha, v2.almanac.sha.idx, @"datev2: --- 煞方向错误! %@ - %@ %@", @(sha), @(v2.almanac.sha.idx), date);
        // 详细见 MCAlmanac.m line 39
        NSString *ss = shaStr(sha);
        test = v2.almanac.sha;
        XCTAssertTrue([ss isEqualToString:test], @"datev2: --- 煞方向错误! %@ - %@ %@", ss, test, date);
    }];
}

// 测试黄历时辰宜忌
- (void)testHuangliDetail {
    __weak typeof(self) self_weak_ = self;
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        NSDictionary *detail = [dayInfo detailHuangLiOfSolar:solar];
        int noNeed4Check = [self_weak_ _defectTime:date];
        
        for (int i = 0; i < 12; i++) {
            NSString *y = detail[[NSString stringWithFormat:@"Yi%d", i]];
            NSString *j = detail[[NSString stringWithFormat:@"Ji%d", i]];
            // 时辰宜忌
            YLAlmanacTime *time = v2.almanac.almanacTimes[i];
            NSString *test = time.yiJi.yi;
            XCTAssertTrue([y isEqualToString:test], @"datev2: --- 时辰宜忌宜错误! %@ - %@ %@", y, test, date);
            test = time.yiJi.ji;
            XCTAssertTrue([j isEqualToString:test], @"datev2: --- 时辰宜忌忌错误! %@ - %@ %@", j, test, date);
            
            // 财喜罗盘
            int value = i * 2;
            if (noNeed4Check >= 0 && value == noNeed4Check) {
                // 误差时间，不做校验，以 YLAlmanacTime 为准。
                NSLog(@"datev2: --- %@.%02d.%02d %02d:00:00 不检验", @(date.ylYear), (int)date.ylMonth, (int)date.ylDay, value);
                continue;
            }
            YLDate *lDate = [YLDate ylDateWithYear:date.ylYear
                                             Month:date.ylMonth
                                               Day:date.ylDay
                                              Hour:value
                                            Minute:0
                                            Second:0];
            ExtDateTime *lExtDateTime = [ExtDateTime dateTimeWithNSDate:lDate];
            
            CompassDirection cai = [ExtDayInfo.extDayInfoManager caiCompassOfDate:lExtDateTime
                                                                       ignoreTime:NO];
            CompassDirection xi = [ExtDayInfo.extDayInfoManager xiCompassOfDate:lExtDateTime
                                                                     ignoreTime:NO];
            CompassDirection fu = [ExtDayInfo.extDayInfoManager fuCompassOfDate:lExtDateTime
                                                                     ignoreTime:NO];
            JXStatus jx = [ExtDayInfo.extDayInfoManager jixiongStatusOfDateTime:lDate];
            
            NSInteger chong = [ExtDayInfo.extDayInfoManager chongIndexOfDateTime:lExtDateTime
                                                                      ignoreTime:NO];
            CompassDirection sha = [ExtDayInfo.extDayInfoManager shaDirectionOfDateTime:lExtDateTime
                                                                             ignoreTime:NO];
            XCTAssertEqual(cai, time.cai.idx, @"datev2: --- 时辰财神罗盘方向错误! %@ - %@ %@", @(cai), @(time.cai.idx), lDate);
            XCTAssertEqual(xi, time.xi.idx, @"datev2: --- 时辰喜神罗盘方向错误! %@ - %@ %@", @(xi), @(time.xi.idx), lDate);
            XCTAssertEqual(fu, time.fu.idx, @"datev2: --- 时辰福神罗盘方向错误! %@ - %@ %@", @(fu), @(time.fu.idx), lDate);
            XCTAssertEqual((int)jx, (int)time.jxStatus, @"datev2: --- 时辰吉凶错误! %@ - %@ %@", @(jx), @(time.jxStatus), lDate);
            XCTAssertEqual(chong, time.chong.idx, @"datev2: --- 时辰冲下标错误! %@ - %@ %@", @(chong), @(time.chong.idx), lDate);
            XCTAssertEqual(sha, time.sha.idx, @"datev2: --- 时辰煞方向错误! %@ - %@ %@", @(sha), @(time.sha.idx), lDate);
        }
    }];
}

// 测试九宫飞星
- (void)testFeixing {
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        NSInteger fx = [YLDate getYearFXOfDate:date];
        XCTAssertEqual(fx - 1, v2.almanac.yearFeixing.idx, @"datev2: --- 年飞星下标错误! %@", date);
        NSString *s1 = [YLDate getFXStrOfIndex:fx];
        NSString *s2 = v2.almanac.yearFeixing;
        XCTAssertTrue([s1 isEqualToString:s2], @"datev2: --- 年飞星错误! %@", date);

        fx = [YLDate getMonthFXOfDate:date.date];
        XCTAssertEqual(fx - 1, v2.almanac.monthFeixing.idx, @"datev2: --- 月飞星下标错误! %@", date);
        
        fx = [YLDate getFXOfDate:date.date];
        XCTAssertEqual(fx - 1, v2.almanac.dayFeixing.idx, @"datev2: --- 日飞星下标错误! %@", date);
    }];
}

#pragma mark - 重构过程中发现的一些小东西
- (void)testHour {
    __weak typeof(self) self_weak_ = self;
    [self _loop:^(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo) {
        [self_weak_ _testHour:date
                           v2:v2];
    }];
}

#pragma mark - Tools
- (void)_loop:(void (^)(YLDate *date, YLDateV2 *v2, ExtDateTime *solar, ExtDateTime *lunar, Lunar *lunarMgr, ExtDayInfo *dayInfo))callback {
    // 数据从 1900.01.01 12:00:00 一直检测到 2099.12.31 12:00:00
    YLDate *date = [YLDate ylDateWithYear:1900
                                    Month:1
                                      Day:1
                                     Hour:12
                                   Minute:0
                                   Second:0];
    YLDateV2 *v2 = [YLDateV2 dateWithYear:1900
                                       month:1
                                         day:1
                                        hour:12
                                      minute:0
                                      second:0];
    NSInteger days = [[YLDateV2 dateWithYear:2099
                                       month:12
                                         day:31
                                        hour:12
                                      minute:0
                                      second:0] daysSince:v2];
    ExtDayInfo *dayInfo = ExtDayInfo.extDayInfoManager;
    Lunar *lunarMgr = dayInfo.lunarMgr;
    do {
        @autoreleasepool {
            ExtDateTime *solar = [ExtDateTime dateTimeWithNSDate:date];
            ExtDateTime *lunar = [lunarMgr lunarFromSolar:solar];
            if (callback) {
                callback(date, v2, solar, lunar, lunarMgr, dayInfo);
            }
            
            date = [date ylAddDays:1];
            v2 = [v2 daysOffset:1];
            days--;
        }
    } while (days >= 0);
}

- (void)_testSolar:(YLDate *)date
                v2:(YLDateV2 *)v2 {
    XCTAssertEqual(date.ylYear, v2.solar.year, @"年份错误! %@", date);
    XCTAssertEqual(date.ylMonth, v2.solar.month, @"月份错误! %@", date);
    XCTAssertEqual(date.ylDay, v2.solar.day, @"日期错误! %@", date);
    XCTAssertEqual(date.ylHour, v2.solar.hour, @"时错误! %@", date);
    XCTAssertEqual(date.ylMinute, v2.solar.minute, @"分错误! %@", date);
    XCTAssertEqual(date.ylSecond, v2.solar.second, @"秒错误! %@", date);
    XCTAssertEqual(date.ylWeekday, v2.solar.weekday, @"周几错误! %@", date);
    XCTAssertEqual(date.ylWeekdayOrdinal, v2.solar.weekdayOrdinal, @"第几个周几错误! %@", date);
    XCTAssertEqual(date.ylWeekOfYear, v2.solar.weekOfYear, @"年第几周错误! %@", date);
    XCTAssertEqual(date.ylMaxDayCountsOfThisMonth, v2.solar.maxDayCountsOfThisMonth, @"月最大天数错误! %@", date);
    XCTAssertEqual(date.ylMaxDayCountsOfThisYear, v2.solar.maxDayCountsOfThisYear, @"年最大天数错误! %@", date);
    XCTAssertEqual(date.isLeapYear, v2.solar.isLeapYear, @"是否闰年错误! %@", date);
}

#pragma mark - expound
// 获取误差时间 @see +_testHour:v2:
- (int)_defectTime:(YLDate *)date {
    int defect0[13] = {19400601, 19410315, 19420131, 19460515, 19470415, 19480501, 19490501, 19860504, 19870412, 19880417, 19890416, 19900415, 19910414};
    int time = (int)(date.ylYear * 10000 + date.ylMonth * 100 + date.ylDay);
    int (^compar)(const void *a, const void *b) = ^int(const void *a, const void *b) {
        int ia = *(int *)a, ib = *(int *)b;
        return ia - ib;
    };
    int *found = (int *)bsearch_b(&time, defect0, 13, sizeof(int), compar);
    if (found) {
        if (*found >= 19860504) { return 2; }
        return 0;
    }
    return -1;
}

// 某些特定时间，使用NSDateComponents 初始化 NSDate 初始化，获取到的 hour 是错误的
// 这些错误的时间有：
//      初始化时间             得到的 NSDate 的时间                    实际误差
// 1940.06.01 00:00:00      1940.06.01 01:00:00   00:00:00 ~ 00:59:59 这段时间段内初始化的时间，都会变成对应的 01:mm:ss
// 1941.03.15 00:00:00      1941.03.15 01:00:00                     同上
// 1942.01.31 00:00:00      1942.01.31 01:00:00                     同上
// 1946.05.15 00:00:00      1946.05.15 01:00:00                     同上
// 1947.04.15 00:00:00      1947.04.15 01:00:00                     同上
// 1948.05.01 00:00:00      1948.05.01 01:00:00                     同上
// 1949.05.01 00:00:00      1949.05.01 01:00:00                     同上
// 1986.05.04 02:00:00      1986.05.04 03:00:00   02:00:00 ~ 02:59:59 这段时间段内初始化的时间，都会变成对应的 03:mm:ss
// 1987.04.12 02:00:00      1987.04.12 03:00:00                     同上
// 1988.04.17 02:00:00      1988.04.17 03:00:00                     同上
// 1989.04.16 02:00:00      1989.04.16 03:00:00                     同上
// 1990.04.15 02:00:00      1990.04.15 03:00:00                     同上
// 1991.04.14 02:00:00      1991.04.14 03:00:00                     同上
// 为什么会有这样的结果，网上没找到解释。
// 而由此还发现的其它问题，可以详细看 +_testTimestamp 方法
// 调用下面的方法，可以获得以上的误差数据结果
- (void)_testHour:(YLDate *)date
               v2:(YLDateV2 *)v2 {
    for (int i = 0; i < 12; i++) {
        int hour = i * 2;
        YLDate *time = [YLDate ylDateWithYear:date.ylYear
                                        Month:date.ylMonth
                                          Day:date.ylDay
                                         Hour:hour
                                       Minute:0
                                       Second:0];
        if (date.ylDay != time.ylDay) {
            NSLog(@"datev2: --- 日期都错误了！！！%@-%@-%@", @(date.ylYear), @(date.ylMonth), @(date.ylDay));
        }
        if (hour != time.ylHour) {
            NSLog(@"datev2: --- 时间与初始化时间不一致! %@-%02d-%02d %d - %@", @(date.ylYear), (int)date.ylMonth, (int)date.ylDay, hour, @(time.ylHour));
            [self _testSecond:date];
        }
    }
}

- (void)_testSecond:(YLDate *)date {
    BOOL hl = NO, ml = NO;
    for (int h = 0; h < 24; h++) {
        for (int m = 0; m < 60; m++) {
            for (int s = 0; s < 60; s++) {
                YLDate *time = [YLDate ylDateWithYear:date.ylYear
                                                Month:date.ylMonth
                                                  Day:date.ylDay
                                                 Hour:h
                                               Minute:m
                                               Second:s];
                if (h != time.ylHour && !hl) {
                    hl = YES;
                    NSLog(@"datev2: --- h: %d %d", h, (int)time.ylHour);
                }
                if (m != time.ylMinute && !ml) {
                    ml = YES;
                    NSLog(@"datev2: --- m: %d %d", m, (int)time.ylMinute);
                }
                if (s != time.ylSecond) {
                    NSLog(@"datev2: --- s: %d %d", s, (int)time.ylSecond);
                }
            }
            ml = NO;
        }
        hl = NO;
    }
}

// 由 +_testHour:v2: 方法引申出的校验。因为初始化时间时却获得了错误的结果，但时间戳是连续的，所以便引发出思考: 使用时间戳初始化是否能获得正确的时间？
// 结果是: NO
// 那些时间确实无法初始化得到，并且发现，按照时间戳初始化的时间，与实际时间存在的误差范围更大。
// 但这些时间在1991年以后已经没有了，因此不存在什么大的影响。
// 调用下面的方法可以看到部分时间的误差。
// 注意，这个方法是按照秒来循环跑的，因此计算量及其大，会花费大量的时间，因此只给出部分时间范围内的结果，不会将整体结果跑出来。
// 需要看完整结果，或有兴趣的，可以修改以下方法来运行
- (void)testTimestamp {
    NSTimeInterval interval = -631180800; // 1950-01-01 00:00:00 //-190454400; // 1963.12.20 00:00:00
    int h = 0;
    int m = 0;
    int s = 0;
    BOOL wrong = NO;
    NSLog(@"datev2: --- 数据检测开始");
    while (interval >= -2209017600) { // 结束时间为1900-01-01 00:00:00 时间戳
        @autoreleasepool {
            interval--;
            s += 59;
            s %= 60;
            if (s == 59) {
                m += 59;
                m %= 60;
                if (m == 59) {
                    h += 23;
                    h %= 24;
                }
            }
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
            YLDate *time = [YLDate ylDateWithDate:date];
            BOOL right = h == time.ylHour && m == time.ylMinute && s == time.ylSecond;
            if (!right) {
                if (!wrong) {
                    NSLog(@"datev2: --- 时间戳与时间开始有差异: %04d-%02d-%02d %02d:%02d:%02d", (int)time.ylYear, (int)time.ylMonth, (int)time.ylDay, (int)time.ylHour, (int)time.ylMinute, (int)time.ylSecond);
                    wrong = YES;
                }
            } else {
                if (wrong) {
                    NSLog(@"datev2: --- 时间戳与时间开始被修复: %04d-%02d-%02d %02d:%02d:%02d", (int)time.ylYear, (int)time.ylMonth, (int)time.ylDay, (int)time.ylHour, (int)time.ylMinute, (int)time.ylSecond);
                    wrong = NO;
                }
            }
        }
    }
    NSLog(@"datev2: --- 数据检测完成");
}

@end
