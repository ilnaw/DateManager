//
//  YLAlmanacTime.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/14.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLDateUnit.h"

NS_ASSUME_NONNULL_BEGIN

/** 罗盘方向 */
typedef NS_ENUM(NSInteger, YLCompassDirection) {
    /** 未知 */
    YLCompassDirectionUnknown   = 0,
    /** 正北 */
    YLCompassDirectionNorth     = 1,
    /** 东北 */
    YLCompassDirectionNortheast = 2,
    /** 正东 */
    YLCompassDirectionEast      = 3,
    /** 东南 */
    YLCompassDirectionSoutheast = 4,
    /** 正南 */
    YLCompassDirectionSouth     = 5,
    /** 西南 */
    YLCompassDirectionSouthwest = 6,
    /** 正西 */
    YLCompassDirectionWest      = 7,
    /** 西北 */
    YLCompassDirectionNorthwest = 8
};

/** 吉凶状态 */
typedef NS_ENUM(NSInteger, YLJiXiongStatus) {
    /** 未知 */
    YLJiXiongStatusUnknown = 0,
    /** 吉 */
    YLJiXiongStatusJi      = 1,
    /** 凶 */
    YLJiXiongStatusXiong   = 2
};

/**
 黄历时辰数据
 --by zwh
 */
@interface YLAlmanacTime : NSObject {
    @private
    /** 日的干支信息 */
    YLStemBranch *_day;
    /** dataProvider */
    NSMutableDictionary<NSString *, id> *_dataProvider;
}

#pragma mark - class method
/**
 与地支相冲的生肖下标
 @param branch 地支下标
 */
+ (NSInteger)chongIndexOfBranch:(NSInteger)branch;
/** 与地支相煞的罗盘方向 */
+ (YLCompassDirection)shaDirectionOfBranch:(NSInteger)branch;
/**
 财神罗盘方向
 @param stem 天干下标
 */
+ (YLCompassDirection)caiDirectionOfStem:(NSInteger)stem;
/** 喜神罗盘方向 */
+ (YLCompassDirection)xiDirectionOfStem:(NSInteger)stem;
/** 福神罗盘方向 */
+ (YLCompassDirection)fuDirectionOfStem:(NSInteger)stem;
/** 阳贵罗盘方向 */
+ (YLCompassDirection)yangDirectionOfStem:(NSInteger)stem;
/** 阴贵罗盘方向 */
+ (YLCompassDirection)yinDirectionOfStem:(NSInteger)stem;
/** 罗盘方向(未知、正北...共9个) */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *compassDirections;

#pragma mark - 时辰
/** 当前时辰数据所处时辰 */
@property (nonatomic, strong, readonly) YLStemBranch *hour;
#pragma mark - 冲煞
/** 冲 @warning idx = 0 name = 鼠 */
@property (nonatomic, strong, readonly) YLDateUnit *chong;
/** 煞
 @warning idx = 0 name = 未知, idx = 1 name = 北
 idx 同 YLCompassDirection 枚举。正北/正南等方向的'正'已经移除 */
@property (nonatomic, strong, readonly) YLDateUnit *sha;
#pragma mark - 财喜罗盘
/** 财神 @warning idx = 0, name = 未知, idx 与 YLCompassDirection 枚举值一致 */
@property (nonatomic, strong, readonly) YLDateUnit *cai;
/** 喜神, 同上 */
@property (nonatomic, strong, readonly) YLDateUnit *xi;
/** 福神, 同上 */
@property (nonatomic, strong, readonly) YLDateUnit *fu;
/** 阳贵, 同上 */
@property (nonatomic, strong, readonly) YLDateUnit *yang;
/** 阴贵, 同上 */
@property (nonatomic, strong, readonly) YLDateUnit *yin;
/** 时辰吉凶状态 */
@property (nonatomic, readonly) YLJiXiongStatus jxStatus;

#pragma mark - Initializer
/**
 初始化方法

 @param hour 时辰的干支数据
 @param day  日的干支数据
 */
+ (instancetype)timeWith:(YLStemBranch *)hour
                   inDay:(YLStemBranch *)day;

@end

/**
 黄历时辰数据分类。仅声明头文件，具体实现，请结合实际 data provider。
 --by zwh
 */
@interface YLAlmanacTime (DataProvider)

/** 时辰宜忌 */
@property (nonatomic, strong, readonly) YLYiJi *yiJi;

@end

NS_ASSUME_NONNULL_END
