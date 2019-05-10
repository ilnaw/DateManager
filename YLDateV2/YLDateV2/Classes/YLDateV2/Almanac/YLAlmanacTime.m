//
//  YLAlmanacTime.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/14.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLAlmanacTime.h"
#import "YLLunar.h"
#import "YLLunarData.h"

@implementation YLAlmanacTime

@synthesize chong = _chong, sha = _sha, cai = _cai, xi = _xi;
@synthesize fu = _fu, yang = _yang, yin = _yin, jxStatus = _jxStatus;

#pragma mark - class method
+ (NSInteger)chongIndexOfBranch:(NSInteger)branch {
    // 与地支对应生肖 +6 的生肖相冲
    return (branch + 6) % 12;
}
+ (YLCompassDirection)shaDirectionOfBranch:(NSInteger)branch {
    return (YLCompassDirection)(((branch % 4) * 6 + 5) % 8);
}

+ (YLCompassDirection)caiDirectionOfStem:(NSInteger)stem {
    /* 甲艮乙坤丙丁兑；戊己财神坐坎位；庚辛正东壬癸南；此是财神正方位。*/
    YLCompassDirection direction = YLCompassDirectionUnknown;
    if (stem <= 1) {
        direction = stem * 4 + 2;
    } else if (stem <= 9) {
        direction = ((stem / 2 + 2) * 2) % 8 + 1;
    }
    return direction;
}

+ (YLCompassDirection)xiDirectionOfStem:(NSInteger)stem {
    /* 甲己在艮乙庚乾；丙辛坤位喜神安；丁壬只在离中坐；戊癸原在巽中间。*/
    NSInteger x = stem % 5;
    NSInteger y = x;
    y = MAX(2, y);
    return (YLCompassDirection)((6 * x) % 8 + y);
}

+ (YLCompassDirection)fuDirectionOfStem:(NSInteger)stem {
    /* 甲己正北是福神；丙辛西北乾宫存；乙庚坤位戊癸艮；丁壬巽上妙追寻。
       其它地方查到的福神与这句口诀都不相符：甲乙：东南、丙丁：东、庚辛：西南、戊：北、己：南、壬：西北、癸：西 */
    YLCompassDirection direction = YLCompassDirectionUnknown;
    switch (stem) {
        case 0:   // 甲
        case 1: { // 乙
            direction = YLCompassDirectionSoutheast;
            break;
        }
        case 2:   // 丙
        case 3: { // 丁
            direction = YLCompassDirectionEast;
            break;
        }
        case 4: { // 戊
            direction = YLCompassDirectionNorth;
            break;
        }
        case 5: { // 己
            direction = YLCompassDirectionSouth;
            break;
        }
        case 6:   // 庚
        case 7: { // 辛
            direction = YLCompassDirectionSouthwest;
            break;
        }
        case 8: { // 壬
            direction = YLCompassDirectionNorthwest;
            break;
        }
        case 9: { // 癸
            direction = YLCompassDirectionWest;
            break;
        }
        default: { break; }
    }
    return direction;
}

+ (YLCompassDirection)yangDirectionOfStem:(NSInteger)stem {
    YLCompassDirection direction = YLCompassDirectionUnknown;
    switch (stem) {
        case 0:   // 甲
        case 1: { // 乙
            direction = YLCompassDirectionSouthwest;
            break;
        }
        case 2: { // 丙
            direction = YLCompassDirectionWest;
            break;
        }
        case 3: { // 丁
            direction = YLCompassDirectionNorthwest;
            break;
        }
        case 4:   // 戊
        case 6:   // 庚
        case 7: { // 辛
            direction = YLCompassDirectionNortheast;
            break;
        }
        case 5: { // 己
            direction = YLCompassDirectionNorth;
            break;
        }
        case 8: { // 壬
            direction = YLCompassDirectionEast;
            break;
        }
        case 9: { // 癸
            direction = YLCompassDirectionSoutheast;
            break;
        }
        default: { break; }
    }
    return direction;
}

+ (YLCompassDirection)yinDirectionOfStem:(NSInteger)stem {
    YLCompassDirection direction = YLCompassDirectionUnknown;
    switch (stem) {
        case 0: { // 甲
            direction = YLCompassDirectionNortheast;
            break;
        }
        case 1: { // 乙
            direction = YLCompassDirectionNorth;
            break;
        }
        case 2: { // 丙
            direction = YLCompassDirectionNorthwest;
            break;
        }
        case 3: { // 丁
            direction = YLCompassDirectionWest;
            break;
        }
        case 4:   // 戊
        case 5:   // 己
        case 6: { // 庚
            direction = YLCompassDirectionSouthwest;
            break;
        }
        case 7: { // 辛
            direction = YLCompassDirectionSouth;
            break;
        }
        case 8: { // 壬
            direction = YLCompassDirectionSoutheast;
            break;
        }
        case 9: { // 癸
            direction = YLCompassDirectionEast;
            break;
        }
        default: { break; }
    }
    return direction;
}

+ (NSArray<NSString *> *)compassDirections {
    return @[@"未知", @"正北", @"东北",
             @"正东", @"东南", @"正南",
             @"西南", @"正西", @"西北"];
}

#pragma mark - getters
- (YLDateUnit *)chong {
    if (!_chong) {
        NSInteger idx = [self.class chongIndexOfBranch:self.hour.branch.idx];
        _chong = [YLDateUnit unitWith:YLLunar.animals[idx]
                                  idx:idx];
    }
    return _chong;
}

- (YLDateUnit *)sha {
    if (!_sha) {
        NSInteger idx = [self.class shaDirectionOfBranch:self.hour.branch.idx];
        NSString *direction = self.class.compassDirections[idx];
        if ([direction hasPrefix:@"正"]) {
            direction = [direction substringFromIndex:1];
        }
        _sha = [YLDateUnit unitWith:direction
                                idx:idx];
    }
    return _sha;
}

- (YLDateUnit *)cai {
    if (!_cai) {
        NSInteger idx = [self.class caiDirectionOfStem:self.hour.stem.idx];
        _cai = [YLDateUnit unitWith:self.class.compassDirections[idx]
                                idx:idx];
    }
    return _cai;
}

- (YLDateUnit *)xi {
    if (!_xi) {
        NSInteger idx = [self.class xiDirectionOfStem:self.hour.stem.idx];
        _xi = [YLDateUnit unitWith:self.class.compassDirections[idx]
                               idx:idx];
    }
    return _xi;
}

- (YLDateUnit *)fu {
    if (!_fu) {
        NSInteger idx = [self.class fuDirectionOfStem:self.hour.stem.idx];
        _fu = [YLDateUnit unitWith:self.class.compassDirections[idx]
                               idx:idx];
    }
    return _fu;
}

- (YLDateUnit *)yang {
    if (!_yang) {
        NSInteger idx = [self.class yangDirectionOfStem:self.hour.stem.idx];
        _yang = [YLDateUnit unitWith:self.class.compassDirections[idx]
                                 idx:idx];
    }
    return _yang;
}

- (YLDateUnit *)yin {
    if (!_yin) {
        NSInteger idx = [self.class yinDirectionOfStem:self.hour.stem.idx];
        _yin = [YLDateUnit unitWith:self.class.compassDirections[idx]
                                idx:idx];
    }
    return _yin;
}

- (YLJiXiongStatus)jxStatus {
    if (_jxStatus == YLJiXiongStatusUnknown) {
        NSInteger idx = ylStemBranchIndexOf(_day.stem.idx, _day.branch.idx);
        unsigned int hex = YLJiXiongTable[idx];
        NSInteger p = 11 - self.hour.branch.idx;
        unsigned int h = (hex >> p) & 0x1;
        _jxStatus = h > 0 ? YLJiXiongStatusJi : YLJiXiongStatusXiong;
    }
    return _jxStatus;
}

+ (instancetype)timeWith:(YLStemBranch *)hour
                   inDay:(YLStemBranch *)day {
    YLAlmanacTime *time = YLAlmanacTime.new;
    time->_hour = hour;
    time->_day = day;
    time->_dataProvider = NSMutableDictionary.new;
    return time;
}

@end
