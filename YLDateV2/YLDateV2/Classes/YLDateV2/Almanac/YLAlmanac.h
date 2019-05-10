//
//  YLAlmanac.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/3.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "_YLDate.h"
#import "YLDateUnit.h"
#import "YLAlmanacTime.h"

NS_ASSUME_NONNULL_BEGIN

/**
 黄历类
 包含二十四节气、干支、吉凶宜忌等
 @warning 不要直接使用
 主类仅提供可以进行推算给出的数据，无法推算或数据量过大的，放在 dataProvider 中实现，并结合实际数据格式，进行数据支持。
 --by zwh
 */
@interface YLAlmanac : _YLDate {
    @private
    /** 现代文解释。类似值神、宜忌、胎神等 */
    NSMutableDictionary<NSString *, NSString *> *_explains;
    /** dataProvider */
    NSMutableDictionary<NSString *, id> *_dataProvider;
    
    /** 当日吉凶 */
    NSInteger _jx;
}

#pragma mark - class property & method
/** 24节气名称(算法以新历年划分。即顺序为：小寒、大寒，立春...共24个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *the24Terms;
/** 天干(甲、乙、丙、丁...共10个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *stems;
/** 地支(子、丑、寅、卯...共12个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *branches;
/** 值神(青龙、明堂、天刑...共12个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *zhiShens;
/** 建除(建、除、满...共12个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *jianChus;
/** 28星宿(轸水蚓、角木蛟、亢金龙...共28个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *the28Stars;
/** 胎神(占门碓外东南...共62个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *fetuses;
/** 五行(海中金、炉中火、大林木...共30个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *the5Elements;
/** 九宫飞星(一白-贪狼星(水)...共9个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *the9Feixing;
/** 九宫飞星对应的解释(吉星，五行属水...共9个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *explainsOfThe9Feixing;

#pragma mark - 二十四节气
/** 节气 @warning idx = 0 name = 小寒。如果这一天没有节气，则为 nil */
@property (nonatomic, strong, readonly, nullable) YLDateUnit *term;
/** 节气时间。如果当天不是节气，则返回 nil */
@property (nonatomic, strong, readonly, nullable) YLTermTime *termTime;

#pragma mark - 天干地支
/** 年干支 */
@property (nonatomic, strong, readonly) YLStemBranch *year;
/** 月干支 */
@property (nonatomic, strong, readonly) YLStemBranch *month;
/** 日干支 */
@property (nonatomic, strong, readonly) YLStemBranch *day;
/** 时干支 */
@property (nonatomic, strong, readonly) YLStemBranch *hour;

#pragma mark - 值神
/** 值神 @warning idx = 0 name = 青龙 */
@property (nonatomic, strong, readonly) YLDateUnit *zhiShen;

#pragma mark - 建除
/** 建除 @warning idx = 0 name = 建 */
@property (nonatomic, strong, readonly) YLDateUnit *jianChu;

#pragma mark - 星宿
/** 星宿 @warning idx = 0 name = 轸水蚓宿星 */
@property (nonatomic, strong, readonly) YLDateUnit *star;

#pragma mark - 胎神
/** 胎神 @warning idx = 0 name = 占门碓外东南 */
@property (nonatomic, strong, readonly) YLDateUnit *fetus;

#pragma mark - 彭祖百忌
/** 彭祖百忌 */
@property (nonatomic, strong, readonly) NSString *pengZuBaiJi;

#pragma mark - 五行
/** 五行 @warning idx = 0 name = 海中金 */
@property (nonatomic, strong, readonly) YLDateUnit *the5Element;

#pragma mark - 冲煞
/** 冲 @warning idx = 0 name = 鼠 */
@property (nonatomic, strong, readonly) YLDateUnit *chong;
/** 煞
 @warning idx = 0 name = 未知, idx = 1 name = 北
 idx 同 YLCompassDirection 枚举。正北/正南等方向的'正'已经移除 */
@property (nonatomic, strong, readonly) YLDateUnit *sha;

#pragma mark - 九宫飞星
/** 年飞星 @warning idx = 0 name = 一白-贪狼星(水) */
@property (nonatomic, strong, readonly) YLDateUnit *yearFeixing;
/** 月飞星 @warning idx = 1 name = 二黑-巨门星(土) */
@property (nonatomic, strong, readonly) YLDateUnit *monthFeixing;
/** 日飞星 @warning idx = 2 name = 三碧-禄存星(木) */
@property (nonatomic, strong, readonly) YLDateUnit *dayFeixing;
/** 九宫飞星格子数字，年 */
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *feixingGridYear;
/** 九宫飞星格子数字，月 */
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *feixingGridMonth;
/** 九宫飞星格子数字，日 */
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *feixingGridDay;

@end

/**
 黄历数据分类。仅声明头文件，具体实现，请结合实际 data provider。
 --by zwh
 */
@interface YLAlmanac (DataProvider)

/** 宜忌 */
@property (nonatomic, strong, readonly) YLYiJi *yiJi;
/** 凶神宜忌，吉神宜趋。@warning yi 表示吉神宜趋，ji 表示凶神宜忌 */
@property (nonatomic, strong, readonly) YLYiJi *xiongJiShen;
/** 黄历时辰数据。数组总共12个元素，依次为 子时, 丑时... 的时辰数据 */
@property (nonatomic, strong, readonly) NSArray<YLAlmanacTime *> *almanacTimes;

#pragma mark - explains
/** 值神现代文解释 */
@property (nonatomic, strong, readonly) NSString *zhiShenExplain;
/** 建除现代文解释 */
@property (nonatomic, strong, readonly) NSString *jianChuExplain;
/** 星宿现代文解释 */
@property (nonatomic, strong, readonly) NSString *starExplain;
/** 胎神现代文解释 */
@property (nonatomic, strong, readonly) NSString *fetusExplain;

@end

NS_ASSUME_NONNULL_END
