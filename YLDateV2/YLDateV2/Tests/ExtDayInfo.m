//
//  ExtDayInfo.m
//  Calendar
//
//  Created by Jasonluo on 12/20/11.
//  Copyright (c) 2011 YouLoft.Com. All rights reserved.
//

#import "ExtDayInfo.h"
#import "ExtDateTime.h"
//#import "DataSourceTools.h"    // 仅仅提供了数据库的文件位置，不需要引入
#import "SQLiteHelper.h"
#import "Lunar.h"
//#import "Custom.h"             // 完全未用上
//#import "SharedData.h"         // 节假日的功能，属于业务逻辑，不应该放到这里面处理

#import "NSCalendar+Gregorian.h"

//#import "NSString+YLAds.h"     // 择吉，同节假日，都属于业务逻辑
#import "solarlunar.h"

@interface ExtDayInfo ()

@property (nonatomic, strong) NSLock *lock;

@end

@implementation ExtDayInfo
@synthesize lunarMgr;

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

-(void) reOpenDB {
    NSString *strDB = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"saa.db"];
    [SQLiteHelper close:db];
    db = [SQLiteHelper openDB:strDB];
}
-(id)init {
    self = [super init];
    if (self) {
        NSString *strDB = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"saa.db"];
        db = [SQLiteHelper openDB:strDB];
        self.lunarMgr = [[Lunar alloc] init];
        [self loadFestivals];
    }
    
    return self;
}

-(NSArray*) resultFromArray:(NSArray*)array forYear:(NSInteger)year {
    NSMutableArray *result = [NSMutableArray array];
    if (array && [array count]>0) {
        for (int i=0; i<[array count]; i++) {
            NSDictionary *hd = [array objectAtIndex:i];
            if ([[hd objectForKey:@"Y"] intValue]<= year) {
                [result addObject:hd];
            }
        }
    }
    return [NSArray arrayWithArray:result];
}
-(NSArray*) readResultOfDate:(ExtDateTime*)dt inDic:(NSDictionary*)dic{
    NSArray *array = [dic objectForKey:[NSString stringWithFormat:@"%@%.2ld%.2ld",(dt.IsLunar&&dt.IsLeap?@"a":@""),(long)dt.Month,(long)dt.Day]];
    if (dt.IsLunar && dt.Day == 29) {
        dt.Day+=1;
        if(![lunarMgr solarFromLunar:dt]) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
            [newArray addObjectsFromArray:[dic objectForKey:[NSString stringWithFormat:@"%@%.2ld%.2ld",(dt.IsLunar&&dt.IsLeap?@"a":@""),(long)dt.Month,(long)dt.Day]]];
            array = [NSArray arrayWithArray:newArray];
        }
    }
    return [self resultFromArray:array forYear:dt.Year];
}

-(void) loadFestivals
{
#warning 节假日属于业务逻辑，不在重构范围内，且不应该属于当前类提供的功能，应考虑分类，或只能更明确的单独的类
//    NSData *data = [NSData dataWithContentsOfFile:[[DataSourceTools dstManager] fesFilePathName]];
//    if (!data) {
//        NSString *fileName = @"festivals.txt";
//
//        if ([[SharedData sharedManager] isBECalendar]) {
//            fileName = @"festivals_BE.txt";
//        }else
//        {
//            int vocAreaIndex = [[SharedData sharedManager].vocationArea intValue];
//            switch (vocAreaIndex) {
//                case 0:
//                    fileName = @"festivals.txt";
//                    break;
//                case 1:
//                    fileName = @"festivals_TW.txt";
//                    break;
//                case 2:
//                    fileName = @"festivals_HK.txt";
//                    break;
//                case 3:
//                    fileName = @"festivals_MAC.txt";
//                    break;
//
//                default:
//                    fileName = @"festivals.txt";
//                    break;
//            }
//        }
//
//        data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName]];
//    }
//
//    self.festivals = [data ylObjectFromJSONData];

}

-(void) loadFestivalsWithOutBE
{
#warning 节假日属于业务逻辑，不在重构范围内，且不应该属于当前类提供的功能，应考虑分类，或只能更明确的单独的类
//    NSData *data = [NSData dataWithContentsOfFile:[[DataSourceTools dstManager] fesFilePathNameWithOutBE]];
//    if (!data) {
//        NSString *fileName = @"festivals.txt";
//
//
//            int vocAreaIndex = [[SharedData sharedManager].vocationArea intValue];
//            switch (vocAreaIndex) {
//                case 0:
//                    fileName = @"festivals.txt";
//                    break;
//                case 1:
//                    fileName = @"festivals_TW.txt";
//                    break;
//                case 2:
//                    fileName = @"festivals_HK.txt";
//                    break;
//                case 3:
//                    fileName = @"festivals_MAC.txt";
//                    break;
//
//                default:
//                    fileName = @"festivals.txt";
//                    break;
//            }
//
//        data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName]];
//    }
//    self.festivals = [data ylObjectFromJSONData];
}


-(NSArray*) solarHolidayOfSolar:(ExtDateTime*)solar {
    NSDictionary *solarDic = [self.festivals objectForKey:@"S"];
    NSArray *result = [self readResultOfDate:solar inDic:solarDic];
    return result;
}
-(NSArray*) lunarHolidayOfLunar:(ExtDateTime*)lunar {
    NSDictionary *lunarDic = [self.festivals objectForKey:@"L"];
    NSArray *result = [self readResultOfDate:lunar inDic:lunarDic];
    return result;
}
-(NSArray*) weekHolidayOfSolar:(ExtDateTime*)solar {
    YLDate *solarDate = [solar nsDateValue];
    NSDictionary *wDic = [self.festivals objectForKey:@"W"];
    NSInteger weekdayOrdinal = [solarDate ylWeekdayOrdinal];
    NSInteger weekday = [solarDate ylWeekday];
    NSArray *array = [wDic objectForKey:[NSString stringWithFormat:@"%.2ld%.1ld%.1ld",(long)solar.Month,(long)weekdayOrdinal,(long)weekday]];
    NSArray *array2 = nil;
    YLDate *testDate = [solarDate ylAddDays:7];
    if ([testDate ylMonth] != [solarDate ylMonth]) {
        array2 = [wDic objectForKey:[NSString stringWithFormat:@"%.2ld%.1ld%.1ld",(long)solar.Month,(long)weekdayOrdinal+1,(long)weekday]];

    }
    NSMutableArray *total = nil;
    if (array && [array count] > 0) {
        total = [NSMutableArray arrayWithArray:array];
    }
    if (array2 && [array2 count] > 0) {
        if (total) {
            for (int i=0; i<[array2 count]; i++) {
                [total addObject:[array2 objectAtIndex:i]];
            }
        }
        else {
            total = [NSMutableArray arrayWithArray:array2];
        }
    }
    
    return [self resultFromArray:total forYear:solar.Year];
}
-(NSString *) explainHuangliStr:(NSString *) huangliStr
{
    [self.lock lock];
    NSArray *array = [SQLiteHelper fetchDB:db usingSQL:[NSString stringWithFormat:@"SELECT * FROM [explain] WHERE [ancient]='%@'",huangliStr]];
    [self.lock unlock];
    if (nil != array && [array count]>0) {
        NSDictionary *dic = [array objectAtIndex:0];
        NSString *exStr = [dic objectForKey:@"prose"];
        return exStr;
    }
    return nil;
}

-(NSString *) explainHuangliStrRetry:(NSString *) huangliStr
{
    [self.lock lock];
    NSArray *array = [SQLiteHelper fetchDB:db usingSQL:[NSString stringWithFormat:@"SELECT * FROM [explain] WHERE [ancient]='%@'",huangliStr]];
    
    if (array.count == 0) {
        // retry
        [self reOpenDB];
        array = [SQLiteHelper fetchDB:db usingSQL:[NSString stringWithFormat:@"SELECT * FROM [explain] WHERE [ancient]='%@'",huangliStr]];
        [self.lock unlock];
    } else {
        [self.lock unlock];
    }
    
    if (nil != array && [array count]>0) {
        NSDictionary *dic = [array objectAtIndex:0];
        NSString *exStr = [dic objectForKey:@"prose"];
        return exStr;
    }
    return nil;
}

-(NSString *) pzExplainStr:(NSString *) pzStr
{
    [self.lock lock];
    NSArray *array = [SQLiteHelper fetchDB:db usingSQL:[NSString stringWithFormat:@"SELECT * FROM [explain] WHERE [ancient]='%@'",pzStr]];
    [self.lock unlock];
    if (nil != array && [array count]>0) {
        NSDictionary *dic = [array objectAtIndex:0];
        NSString *exStr = [dic objectForKey:@"prose"];
        return exStr;
    }
    return nil;
}

-(NSInteger) stemIndexOfSolar:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger stemIndex = -1;
    if (ignoreTime) {
        stemIndex = [self.lunarMgr stemDayOfSolarDate:solar];
    }
    else {
        stemIndex = ([self.lunarMgr stemBranchHourOfSolarDate:solar] % 10);
    }
    return stemIndex;
}

-(NSInteger) branchIndexOfSolar:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger branchIndex = -1;
    if (ignoreTime) {
        branchIndex = [self.lunarMgr branchDayOfSolarDate:solar];
    }
    else {
        branchIndex = ([self.lunarMgr stemBranchHourOfSolarDate:solar] % 12);
    }
    return branchIndex;
}

//
/*坎->正北;坤->西南;震->正东;巽->东南;乾->西北;卦->正西;艮->东北;离->正南*/
//
/*甲艮乙坤丙丁兑；戊己财神坐坎位；庚辛正东壬癸南；此是财神正方位。*/
-(CompassDirection) caiCompassValueOfStemIndex:(NSInteger)stemIndex {
    CompassDirection value = CompassUnknown;
    switch (stemIndex) {
        case 0://甲
            value = CompassNortheast;
            break;
        case 1://乙
            value = CompassSouthwest;
            break;
        case 2://丙
        case 3://丁
            value = CompassWest;
            break;
        case 4://戊
        case 5://己
            value = CompassNorth;
            break;
        case 6://庚
        case 7://辛
            value = CompassEast;
            break;
        case 8://壬
        case 9://癸
            value = CompassSouth;
            break;
        default:
            break;
    }
    return value;
}

-(NSString*) compassDirectionStringFromEnum:(CompassDirection)direction {
    switch (direction) {
        case CompassUnknown:
            return @"未知";
        case CompassEast:
            return @"正东";
        case CompassWest:
            return @"正西";
        case CompassSouth:
            return @"正南";
        case CompassNorth:
            return @"正北";
        case CompassNortheast:
            return @"东北";
        case CompassNorthwest:
            return @"西北";
        case CompassSoutheast:
            return @"东南";
        case CompassSouthwest:
            return @"西南";
        default:
            break;
    }
    return nil;
}
-(NSString*) jixiongStringFromEnum:(JXStatus)status {
    switch (status) {
        case JXStatusJi:
            return @"吉";
        case JXStatusXiong:
            return @"凶";
        case JXStatusUnknown:
            return @"未知";
        default:
            break;
    }
    return nil;
}

-(CompassDirection) caiCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger stemIndex = [self stemIndexOfSolar:solar ignoreTime:ignoreTime];
    return [self caiCompassValueOfStemIndex:stemIndex];
}
/*甲己在艮乙庚乾；丙辛坤位喜神安；丁壬只在离中坐；戊癸原在巽中间。*/
-(CompassDirection) xiCompassValueOfStemIndex:(NSInteger)stemIndex {
    CompassDirection value = CompassUnknown;
    switch (stemIndex) {
        case 0://甲
        case 5://己
            value = CompassNortheast;
            break;
        case 1://乙
        case 6://庚
            value = CompassNorthwest;
            break;
        case 2://丙
        case 7://辛
            value = CompassSouthwest;
            break;
        case 3://丁
        case 8://壬
            value = CompassSouth;
            break;
        case 4://戊
        case 9://癸
            value = CompassSoutheast;
            break;
        default:
            break;
    }
    return value;
}
-(CompassDirection) xiCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger stemIndex = [self stemIndexOfSolar:solar ignoreTime:ignoreTime];
    return [self xiCompassValueOfStemIndex:stemIndex];
}
/*甲己正北是福神；丙辛西北乾宫存；乙庚坤位戊癸艮；丁壬巽上妙追寻。*/
/*其它地方查到的福神与这句口诀都不相符：甲乙：东南、丙丁：东、庚辛：西南、戊：北、己：南、壬：西北、癸：西 */
-(CompassDirection) fuCompassValueOfStemIndex:(NSInteger)stemIndex {
    CompassDirection value = CompassUnknown;
    switch (stemIndex) {
        case 0://甲
        case 1://乙
            value = CompassSoutheast;
            break;
        case 2://丙
        case 3://丁
            value = CompassEast;
            break;
        case 4://戊
            value = CompassNorth;
            break;
        case 5://己
            value = CompassSouth;
            break;
        case 6://庚
        case 7://辛
            value = CompassSouthwest;
            break;
        case 8://壬
            value = CompassNorthwest;
            break;
        case 9://癸
            value = CompassWest;
            break;
        default:
            break;
    }
    return value;
}
-(CompassDirection) nanCompassValueOfStemIndex:(NSInteger)stemIndex {
    CompassDirection value = CompassUnknown;
    switch (stemIndex) {
        case 0://甲
        case 1://乙
            value = CompassSouthwest;
            break;
        case 2://丙
            value = CompassWest;
            break;
        case 3://丁
            value = CompassNorthwest;
            break;
        case 4://戊
        case 6://庚
        case 7://辛
            value = CompassNortheast;
            break;
        case 5://己
            value = CompassNorth;
            break;
        case 8://壬
            value = CompassEast;
            break;
        case 9://癸
            value = CompassSoutheast;
            break;
        default:
            break;
    }
    return value;
}
-(CompassDirection) nvCompassValueOfStemIndex:(NSInteger)stemIndex {
    CompassDirection value = CompassUnknown;
    switch (stemIndex) {
        case 0://甲
            value = CompassNortheast;
            break;
        case 1://乙
            value = CompassNorth;
            break;
        case 2://丙
            value = CompassNorthwest;
            break;
        case 3://丁
            value = CompassWest;
            break;
        case 4://戊
        case 5://己
        case 6://庚
            value = CompassSouthwest;
            break;
        case 7://辛
            value = CompassSouth;
            break;
        case 8://壬
            value = CompassSoutheast;
            break;
        case 9://癸
            value = CompassEast;
            break;
        default:
            break;
    }
    return value;
}
-(CompassDirection) fuCompassOfDate:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger stemIndex = [self stemIndexOfSolar:solar ignoreTime:ignoreTime];
    return [self fuCompassValueOfStemIndex:stemIndex];
}
-(CompassDirection) nanCompassOfDate:(ExtDateTime *)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger stemIndex = [self stemIndexOfSolar:solar ignoreTime:ignoreTime];
    return [self nanCompassValueOfStemIndex:stemIndex];
}
-(CompassDirection) nvCompassOfDate:(ExtDateTime *)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger stemIndex = [self stemIndexOfSolar:solar ignoreTime:ignoreTime];
    return [self nvCompassValueOfStemIndex:stemIndex];
}

-(JXStatus) jixiongStatusOfDateTime:(YLDate*)datetime {
    JXStatus status = JXStatusUnknown;
    ExtDateTime *solar = [ExtDateTime dateTimeWithNSDate:datetime];
    NSInteger stemIndex = [self.lunarMgr stemBranchDayOfSolarDate:solar];
    if (stemIndex > -1 && stemIndex < 60) {
        unsigned int hexValue = JXTable[stemIndex];
        NSInteger chineseHour = [datetime ylChineseNumHour];
        NSInteger moveCount = (11-chineseHour);
        NSInteger value = (hexValue >> moveCount) & 0x1;
        status = value > 0 ? JXStatusJi : JXStatusXiong;
    }
    return status;
}
/*
 子午相冲，丑未相冲，寅申相冲，辰戌相冲，巳亥相冲，卯酉相冲
 */
-(int) chongIndexOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger branchIndex = [self branchIndexOfSolar:solar ignoreTime:ignoreTime];
    int value = -1;
    switch (branchIndex) {
        case 0:value = 6;
            break;
        case 1:value = 7;
            break;
        case 2:value = 8;
            break;
        case 3:value = 9;
            break;
        case 4:value = 10;
            break;
        case 5:value = 11;
            break;
        case 6:value = 0;
            break;
        case 7:value = 1;
            break;
        case 8:value = 2;
            break;
        case 9:value = 3;
            break;
        case 10:value = 4;
            break;
        case 11:value = 5;
            break;
        default:
            break;
    }
    return value;
}
/*
 逢巳日、酉日、丑日必是“煞东”；亥日、卯日、未日必“煞西”；申日、子日、辰日必“煞南”；寅日、午日、戌日必“煞北”
 */
-(CompassDirection) shaDirectionOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger branchIndex = [self branchIndexOfSolar:solar ignoreTime:ignoreTime];
    CompassDirection value = CompassUnknown;
    switch (branchIndex) {
        case 0://子
        case 4://辰
        case 8://申
            value = CompassSouth;
            break;
        case 1://丑
        case 5://巳
        case 9://酉
            value = CompassEast;
            break;
        case 2://寅
        case 6://午
        case 10://戌
            value = CompassNorth;
            break;
        case 3://卯
        case 7://未
        case 11://亥
            value = CompassWest;
            break;
        default:
            break;
    }
    return value;
}

// 4.5.4 hyd 显示地支对应的生肖
-(NSString*) zodiacDayOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger branchIndex = [self branchIndexOfSolar:solar ignoreTime:ignoreTime];
    NSString *value = @"";
    switch (branchIndex) {
        case 0:value = @"鼠";// 子
            break;
        case 4:value = @"龙";// 辰
            break;
        case 8:value = @"猴";// 申
            break;
        case 1:value = @"牛";// 丑
            break;
        case 5:value = @"蛇";// 巳
            break;
        case 9:value = @"鸡";// 酉
            break;
        case 2:value = @"虎";// 寅
            break;
        case 6:value = @"马";// 午
            break;
        case 10:value = @"狗";// 戌
            break;
        case 3:value = @"兔";// 卯
            break;
        case 7:value = @"羊";// 未
            break;
        case 11:value = @"猪";// 亥
            break;
        default:
            break;
    }
    return value;
}
// 4.5.4 hyd 显示生肖对应的地支
-(NSString*) terrestrialBranchDayOfDateTime:(ExtDateTime*)solar ignoreTime:(BOOL)ignoreTime {
    NSInteger branchIndex = [self branchIndexOfSolar:solar ignoreTime:ignoreTime];
    NSString *value = @"";
    switch (branchIndex) {
        case 0:value = @"子";// 鼠
            break;
        case 4:value = @"辰";// 龙
            break;
        case 8:value = @"申";// 猴
            break;
        case 1:value = @"丑";// 牛
            break;
        case 5:value = @"巳";// 蛇
            break;
        case 9:value = @"酉";// 鸡
            break;
        case 2:value = @"寅";// 虎
            break;
        case 6:value = @"午";// 马
            break;
        case 10:value = @"戌";// 狗
            break;
        case 3:value = @"卯";// 兔
            break;
        case 7:value = @"未";// 羊
            break;
        case 11:value = @"亥";// 猪
            break;
        default:
            break;
    }
    return value;
}
-(NSString *) pzbjOfStemBranchValue:(int)sbValue {
    int dayStem = sbValue % 10;
    int dayBranch = sbValue % 12;
    NSArray *stemArray = @[@"甲不开仓财物耗散",@"乙不栽植千株不长",@"丙不修灶必见灾殃",@"丁不剃头头必生疮",@"戊不受田田主不祥",
                           @"己不破券二比并亡",@"庚不经络织机虚张",@"辛不合酱主人不尝",@"壬不汲水更难提防",@"癸不词讼理弱敌强"];
    NSArray *branchArray = @[@"子不问卜自惹祸殃",@"丑不冠带主不还乡",@"寅不祭祀神鬼不尝",@"卯不穿井水泉不香",@"辰不哭泣必主重丧",@"巳不远行财物伏藏",
                             @"午不苫盖屋主更张",@"未不服药毒气入肠",@"申不安床鬼祟入房",@"酉不宴客醉坐颠狂",@"戌不吃犬作怪上床",@"亥不嫁娶不利新郎"];
    return [NSString stringWithFormat:@"%@ %@",[stemArray objectAtIndex:dayStem],[branchArray objectAtIndex:dayBranch]];
}

-(NSString *) wxOfStemBranchStr:(NSString*)sbStr {
    NSDictionary *wuxingDic = @{@"甲子":@"海中金",@"乙丑":@"海中金",
                                @"丙寅":@"炉中火",@"丁卯":@"炉中火",
                                @"戊辰":@"大林木",@"己巳":@"大林木",
                                @"庚午":@"路旁土",@"辛未":@"路旁土",
                                @"壬申":@"剑锋金",@"癸酉":@"剑锋金",
                                @"甲戌":@"山头火",@"乙亥":@"山头火",
                                @"丙子":@"涧下水",@"丁丑":@"涧下水",
                                @"戊寅":@"城头土",@"己卯":@"城头土",
                                @"庚辰":@"白蜡金",@"辛巳":@"白蜡金",
                                @"壬午":@"杨柳木",@"癸未":@"杨柳木",
                                @"甲申":@"泉中水",@"乙酉":@"泉中水",
                                @"丙戌":@"屋上土",@"丁亥":@"屋上土",
                                @"戊子":@"霹雳火",@"己丑":@"霹雳火",
                                @"庚寅":@"松柏木",@"辛卯":@"松柏木",
                                @"壬辰":@"长流水",@"癸巳":@"长流水",
                                @"甲午":@"沙中金",@"乙未":@"沙中金",
                                @"丙申":@"山下火",@"丁酉":@"山下火",
                                @"戊戌":@"平地木",@"己亥":@"平地木",
                                @"庚子":@"壁上土",@"辛丑":@"壁上土",
                                @"壬寅":@"金箔金",@"癸卯":@"金箔金",
                                @"甲辰":@"覆灯火",@"乙巳":@"覆灯火",
                                @"丙午":@"天河水",@"丁未":@"天河水",
                                @"戊申":@"大驿土",@"己酉":@"大驿土",
                                @"庚戌":@"钗钏金",@"辛亥":@"钗钏金",
                                @"壬子":@"桑拓木",@"癸丑":@"桑拓木",
                                @"甲寅":@"大溪水",@"乙卯":@"大溪水",
                                @"丙辰":@"沙中土",@"丁巳":@"沙中土",
                                @"戊午":@"天上火",@"己未":@"天上火",
                                @"庚申":@"石榴木",@"辛酉":@"石榴木",
                                @"壬戌":@"大海水",@"癸亥":@"大海水"
                                };
    return [wuxingDic objectForKey:sbStr];
}

-(NSDictionary*) briefHuangLiOfSolar:(ExtDateTime*)solar {
    solar.Hour = 0;
    solar.Minute = 0;
    solar.Second = 0;

    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
#pragma mark - XSYJ & JSYQ Calc
    int monthBranch = [self.lunarMgr stemBranchMonthOfSolarDate:solar] % 12;
    int value = (monthBranch + 10) % 12 + 1;
    int stemBranchValue = (int)[self.lunarMgr stemBranchDayOfSolarDate:solar];
    NSString *sbStrOfDay = [self.lunarMgr stemBranchStrOfIndex:stemBranchValue];
    NSString *xsjssql = [NSString stringWithFormat:@"SELECT [favonian] AS JSYQ,[terrible] AS XSYJ FROM [advices] where [Code] = %d AND dayGz='%@'",value,sbStrOfDay];
    
    [self.lock lock];
    NSArray *xsjs = [SQLiteHelper fetchDB:db usingSQL:xsjssql];
    if (xsjs.count == 0) {
        [self reOpenDB];
        xsjs = [SQLiteHelper fetchDB:db usingSQL:xsjssql];
        [self.lock unlock];
    } else {
        [self.lock unlock];
    }
    if (xsjs && [xsjs count]> 0) {
        NSDictionary *vdic = [xsjs firstObject];
        [dic setObject:[vdic objectForKey:@"JSYQ"] forKey:@"JSYQ"];
        [dic setObject:[vdic objectForKey:@"XSYJ"] forKey:@"XSYJ"];
    }
#pragma mark - end
    
#pragma mark - PXBJ Calc
    NSString *pzbjStr = [self pzbjOfStemBranchValue:stemBranchValue];
    if (pzbjStr && [pzbjStr length] > 0) {
        [dic setObject:pzbjStr forKey:@"PZBJ"];
    }
    
#pragma mark - end
    
#pragma mark - WX Calc
    NSString *wxStr = [self wxOfStemBranchStr:sbStrOfDay];
    if (wxStr && [wxStr length] > 0) {
        [dic setObject:wxStr forKey:@"WX"];
    }
#pragma mark - end
    
    
#pragma mark - YiJiCalc
    
    int gzIndex = -1;
    int jx = -1;
    int yearOffset = (int)solar.Year - 1900;
    int termValue = (int)[self.lunarMgr termIndexOfDate:solar];
    int b = (termValue != -1);
    int index = -1;
    if (b > 0) {
        index = termValue;
    }
    else {
        index = (int)[self.lunarMgr termIndexBeforeDate:solar] + 1;
    }
    int a = index + yearOffset * 24 - 24;
    int offsetDayCount = a%2==0?a/2:a/2+1;
    if (b&&a%2==0) {
        offsetDayCount+=1;
    }
    
    ExtDateTime *baseDt = [ExtDateTime dateOfYear:1901 ByOffset:0];
    baseDt.Hour = 0;
    baseDt.Minute = 0;
    baseDt.Second = 0;
    
    int day = (int)[solar solarDayIntervalSinceDate:baseDt];
    gzIndex = (15+day)%60;
    jx = (5+day-offsetDayCount)%12;

    NSString *yjsql = [NSString stringWithFormat:@"SELECT [yi] AS Y,[ji] AS Ji FROM [YJData] WHERE [jx]=%d AND [gz]=%d",jx,gzIndex];
    [self.lock lock];
    NSArray *yiji = [SQLiteHelper fetchDB:db usingSQL:yjsql];
    [self.lock unlock];
    if (nil != yiji && [yiji count] >0) {
        NSDictionary *yijiDic = [yiji objectAtIndex:0];
        [dic setObject:[yijiDic objectForKey:@"Y"] forKey:@"Y"];
        [dic setObject:[yijiDic objectForKey:@"Ji"] forKey:@"Ji"];
    }
#pragma mark - end

    return [NSDictionary dictionaryWithDictionary:dic];
}

-(NSDictionary*) detailHuangLiOfSolar:(ExtDateTime*)solar {
    solar = [self _moveDateToLegalDay:solar];
    NSString *strKey = [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld",(long)solar.Year,(long)solar.Month,(long)solar.Day];
    [self.lock lock];
    NSArray *array = [SQLiteHelper fetchDB:db usingSQL:[NSString stringWithFormat:@"SELECT * FROM [DetailHuangLi] WHERE [_Date]='%@'",strKey]];
    [self.lock unlock];
    if (nil != array && [array count]>0) {
        return [array objectAtIndex:0];
    }
    return nil;
}

// 时辰宜忌查询使用。
- (ExtDateTime *)_moveDateToLegalDay:(ExtDateTime *)solar {
    // 从4.8.4分支 迁移过来的逻辑
    // 时辰宜忌保留一组数据，数据时间范围为 2010-01-14(甲子日) ~ 2010-03-14(癸亥日)
    if (solar.Year == 2010 && (solar.Month >= 1 && solar.Month <= 3)) {
        // 日期为2010-01～2010-03
        if ((solar.Month == 2) ||
            (solar.Month == 1 && solar.Day >= 14) ||
            (solar.Month == 3 && solar.Day <= 14)) {
            //  日期为保留数据的日期内，不需要做日期偏移
            return solar;
        }
    }
    
    // 根据日期所在的干支，定位到数据范围内的日期
    NSInteger gzIdx = [self.lunarMgr stemBranchDayOfSolarDate:solar];
    // 甲子日
    YLDate *jz = [YLDate ylDateWithYear:2010
                                  Month:1
                                    Day:14
                                   Hour:12
                                 Minute:0
                                 Second:0];
    // 与给定日期干支相同的日期
    YLDate *theDayWithSameGz = [jz ylAddDays:gzIdx];
    ExtDateTime *moved = [ExtDateTime dateTimeWithNSDate:theDayWithSameGz];
    return moved;
//    if (solar.Year >= 2012 && solar.Year <= 2031) {
//        // 时辰宜忌数据库区间内，不需要处理
//        return solar;
//    }
//
//    ExtDateTime *(^move)(ExtDateTime *date/** 起始日期 */, int toLeapYear/** 转换到某个闰年 */) = ^ExtDateTime *(ExtDateTime *date, int toLeapYear) {
//        // 计算到指定年同月同日需要多少天
//        solar_calendar theDate = solar_creat_date((int)date.Year, (int)date.Month, (int)date.Day);
//        // 因为传进来的指定年份是闰年，所以所有的月日(只要起始日期是合法的，则这一年都存在这个日期)都是合法的
//        solar_calendar legal = solar_creat_date(toLeapYear, (int)solar.Month, (int)solar.Day);
//        BOOL forward = toLeapYear > date.Year;
//        NSInteger days = legal - theDate;
//        if (!forward) { days = -days; }
//
//        // 4.8.3 时辰宜忌查询方法更新，每60天一轮回，所以超出数据库范围的，增加/减少相应轮回数，使其落到数据库范围内
//        ExtDateTime *copy = solar.copy;
//        copy.Year = toLeapYear;
//        // 每60天一轮，计算到指定的年份时，经过整轮后多出了几天
//        NSInteger remainder = days % 60;
//        if (remainder == 0) { return copy; } // 没有余数，说明日期刚刚好
//
//        NSInteger add = 60 - remainder;
//        if (!forward) { add = remainder; }
//        int maxDaysInMonth[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
//        NSInteger day = copy.Day + add;
//        while (day > 0) {
//            int maxDays = maxDaysInMonth[copy.Month - 1];
//            if (copy.Month == 2 && LEAP(copy.Year)) {
//                maxDays = 29;
//            }
//            if (day > maxDays) {
//                copy.Month += 1;
//                if (copy.Month > 12) {
//                    copy.Year += 1;
//                    copy.Month = 1;
//                }
//                day -= maxDays;
//            } else {
//                copy.Day = day;
//                day = 0;
//            }
//        }
//        return copy;
//    };
//
//    if (solar.Year < 2012) {
//        return move(solar, 2012);
//    }
//    return move(solar, 2030);
}

- (NSArray *) allZejiData {
#warning 择吉属于业务逻辑，不在重构范围内，且不应该属于当前类提供的功能，应考虑分类，或只能更明确的单独的类
//    NSString *zjJsonString = FETCHADSFROMURL([@"ZJ_454_" adsString]);
//    if ([zjJsonString length] == 0) {
//        NSURL *zjJsonUrl = [[NSBundle mainBundle] URLForResource:@"SelectYJ" withExtension:@"txt"];
//        zjJsonString = [[NSString alloc] initWithContentsOfURL:zjJsonUrl encoding:NSUTF8StringEncoding error:NULL];
//    }
//
//    if ([zjJsonString length] == 0) {
//        return nil;
//    }
//
//    NSData *zjJsonData = [zjJsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error = nil;
//    NSArray *zjJson = [NSJSONSerialization JSONObjectWithData:zjJsonData options:NSJSONReadingMutableContainers error:&error];
//    if (error == nil && [zjJson isKindOfClass:[NSArray class]]) {
//        return [zjJson copy];
//    }
    
    return nil;
}

-(NSArray*) briefHuangLiBegin:(ExtDateTime*)begin end:(ExtDateTime*)end keyword:(NSString*)keyword yi:(BOOL)yi {
    NSString *beginStr = [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld",(long)begin.Year,(long)begin.Month,(long)begin.Day];
    NSString *endStr = [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld",(long)end.Year,(long)end.Month,(long)end.Day];
    NSString *sql = nil;
    
    if (yi) {
        sql = @"SELECT [YJData].[yi] AS Y,[YJData].[ji] AS Ji,[IndexTable].[_Date] FROM [IndexTable] INNER JOIN [YJData] ON [IndexTable].jx = [YJData].jx AND [IndexTable].gz = [YJData].gz WHERE [_Date] >= '%@' AND [_Date] <= '%@' AND [Y] LIKE '%%%@%%' ORDER BY [_Date]";
    }
    else {
        sql = @"SELECT [YJData].[yi] AS Y,[YJData].[ji] AS Ji,[IndexTable].[_Date] FROM [IndexTable] INNER JOIN [YJData] ON [IndexTable].jx = [YJData].jx AND [IndexTable].gz = [YJData].gz WHERE [_Date] >= '%@' AND [_Date] <= '%@' AND [Ji] LIKE '%%%@%%' ORDER BY [_Date]";
    }

    sql = [NSString stringWithFormat:sql,beginStr,endStr,keyword];
    [self.lock lock];
    NSArray *array = [SQLiteHelper fetchDB:db usingSQL:sql];
    [self.lock unlock];
    return array;
}
-(NSString*) constellationStrOfIndex:(int)index {
    if (nil == _conArray) {
        _conArray = [NSArray arrayWithObjects:@"白羊座",@"金牛座",@"双子座",@"巨蟹座",@"狮子座",@"处女座",@"天秤座",@"天蝎座",@"射手座",@"摩羯座",@"水瓶座",@"双鱼座", nil];
    }
    return [_conArray objectAtIndex:index];
}
-(NSString*) constellationDateStrOfIndex:(int)index {
    switch (index) {
        case 0:
            return @"03.21~04.19";
        case 1:
            return @"04.20~05.20";
        case 2:
            return @"05.21~06.21";
        case 3:
            return @"06.22~07.22";
        case 4:
            return @"07.23~08.22";
        case 5:
            return @"08.23~09.22";
        case 6:
            return @"09.23~10.23";
        case 7:
            return @"10.24~11.22";
        case 8:
            return @"11.23~12.21";
        case 9:
            return @"12.22~01.19";
        case 10:
            return @"01.20~02.18";
        case 11:
            return @"02.19~03.20";
            
        default:
            return @"";
    }
}


-(int) constellationIndexOfSolar:(ExtDateTime*)solar {
    NSInteger Month = solar.Month;
	NSInteger Day = solar.Day;
	
	switch (Month) {
		case 1:
			if (Day<20) {
				return 9;
			}
			return 10;
		case 2:
			if (Day<19) {
				return 10;
			}
			return 11;
		case 3:
			if (Day<21) {
				return 11;
			}
			return 0;
		case 4:
			if (Day<20) {
				return 0;
			}
			return 1;
		case 5:
			if (Day < 21) {
				return 1;
			}
			return 2;
		case 6:
			if (Day < 22) {
				return 2;
			}
			return 3;
		case 7:
			if (Day < 23) {
				return 3;
			}
			return 4;
		case 8:
			if (Day < 23) {
				return 4;
			}
			return 5;
		case 9:
			if (Day < 23) {
				return 5;
			}
			return 6;
		case 10:
			if (Day < 24) {
				return 6;
			}
			return 7;
		case 11:
			if (Day < 23) {
				return 7;
			}
			return 8;
		case 12:
			if (Day < 22) {
				return 8;
			}
			return 9;
		default:
			return -1;
	}
}

-(NSString*) constellationOfSolar:(ExtDateTime*)solar {
	//白羊座3月21日-4月19日	金牛座4月20日-5月20日	双子座5月21日-6月21日	巨蟹座6月22日-7月22日	狮子座7月23日-8月22日	处女座8月23日-9月22日	天秤座9月23日-10月23日	天蝎座10月24日-11月22日	射手座11月23日-12月21日	摩羯座12月22日-1月19日	水瓶座1月20日-2月18日	双鱼座2月19日-3月20日
    int index =[self constellationIndexOfSolar:solar];
    if (index > -1) {
        return [self constellationStrOfIndex:index];
    }
    return @"N/A";
}

-(NSMutableArray *) festivalsInfoWithDate:(YLDate *) selectedDate includeWestFes:(BOOL) addWestFes includeBEFes:(BOOL) addBEFes
{
#warning 节假日属于业务逻辑，不在重构范围内，且不应该属于当前类提供的功能，应考虑分类，或只能更明确的单独的类
    return nil;
//    ExtDayInfo *extDayInfo = [ExtDayInfo extDayInfoManager];
//    Lunar *lunar = extDayInfo.lunarMgr;
//
//    ExtDateTime *solardt = [ExtDateTime dateTimeWithNSDate:selectedDate];
//    ExtDateTime *lunardt = [lunar lunarFromSolar:solardt];
//
//    NSArray *la = [extDayInfo lunarHolidayOfLunar:lunardt];
//    NSArray *sa = [extDayInfo solarHolidayOfSolar:solardt];
//    NSArray *wa = [extDayInfo weekHolidayOfSolar:solardt];
//
//    if (addBEFes) {
//
//        //月斋
//        if (lunardt.Month == 1 ||
//            lunardt.Month == 5 ||
//            lunardt.Month == 9) {
//            if (lunardt.Day == 1) {
//                NSMutableArray *mla = [NSMutableArray arrayWithArray:la];
//                if (mla == nil) {
//                    mla = [NSMutableArray array];
//                }
//                NSDictionary *fesInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"月斋",@"V",@"7",@"P",@"1899",@"Y", nil];
//                [mla addObject:fesInfo];
//                la = [mla copy];
//            }
//        }
//
//        //朔望斋
//        if (lunardt.Day == 1 ||
//            lunardt.Day == 15)
//        {
//            NSMutableArray *mla = [NSMutableArray arrayWithArray:la];
//            if (mla == nil) {
//                mla = [NSMutableArray array];
//            }
//            NSDictionary *fesInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"朔望斋",@"V",@"6",@"P",@"1899",@"Y", nil];
//            [mla addObject:fesInfo];
//            la = [mla copy];
//        }
//
//
//        //计算是否是地藏斋
//        if (lunardt.Day == 1 ||
//            lunardt.Day == 8 ||
//            lunardt.Day == 14 ||
//            lunardt.Day == 15 ||
//            lunardt.Day == 18 ||
//            lunardt.Day == 23 ||
//            lunardt.Day == 24 ||
//            lunardt.Day == 28 ||
//            lunardt.Day == 29 ||
//            lunardt.Day == 30)
//        {
//            NSMutableArray *mla = [NSMutableArray arrayWithArray:la];
//            if (mla == nil) {
//                mla = [NSMutableArray array];
//            }
//            NSDictionary *fesInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"地藏斋",@"V",@"5",@"P",@"1899",@"Y", nil];
//            [mla addObject:fesInfo];
//            la = [mla copy];
//        }
//
//        //六斋
//        if (lunardt.Day == 8 ||
//            lunardt.Day == 14 ||
//            lunardt.Day == 15 ||
//            lunardt.Day == 23 ||
//            lunardt.Day == 28 ||
//            lunardt.Day == 29 ||
//            lunardt.Day == 30)
//        {
//            NSInteger monthDayCount = [[ExtDayInfo extDayInfoManager].lunarMgr lunarMaxDayOfMonth:lunardt.Month inYear:lunardt.Year isLeap:lunardt.IsLeap];
//
//            if (monthDayCount == 30 && lunardt.Day == 28) {//大月
//
//            }else
//            {
//                NSMutableArray *mla = [NSMutableArray arrayWithArray:la];
//                if (mla == nil) {
//                    mla = [NSMutableArray array];
//                }
//                NSDictionary *fesInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"六斋",@"V",@"5",@"P",@"1899",@"Y", nil];
//                [mla addObject:fesInfo];
//                la = [mla copy];
//            }
//        }
//
//        //观音斋
//        if ((lunardt.Month == 1 && lunardt.Day == 8) ||
//            (lunardt.Month == 2 && lunardt.Day == 7) ||
//            (lunardt.Month == 2 && lunardt.Day == 9) ||
//            (lunardt.Month == 2 && lunardt.Day == 19) ||
//            (lunardt.Month == 3 && lunardt.Day == 3) ||
//            (lunardt.Month == 3 && lunardt.Day == 6) ||
//            (lunardt.Month == 3 && lunardt.Day == 13) ||
//            (lunardt.Month == 4 && lunardt.Day == 22) ||
//            (lunardt.Month == 5 && lunardt.Day == 3) ||
//            (lunardt.Month == 5 && lunardt.Day == 17) ||
//            (lunardt.Month == 6 && lunardt.Day == 16) ||
//            (lunardt.Month == 6 && lunardt.Day == 18) ||
//            (lunardt.Month == 6 && lunardt.Day == 19) ||
//            (lunardt.Month == 6 && lunardt.Day == 23) ||
//            (lunardt.Month == 7 && lunardt.Day == 13) ||
//            (lunardt.Month == 8 && lunardt.Day == 16) ||
//            (lunardt.Month == 9 && lunardt.Day == 19) ||
//            (lunardt.Month == 9 && lunardt.Day == 23) ||
//            (lunardt.Month == 10 && lunardt.Day == 2) ||
//            (lunardt.Month == 11 && lunardt.Day == 19) ||
//            (lunardt.Month == 11 && lunardt.Day == 24) ||
//            (lunardt.Month == 12 && lunardt.Day == 25) )
//        {
//            NSMutableArray *mla = [NSMutableArray arrayWithArray:la];
//            if (mla == nil) {
//                mla = [NSMutableArray array];
//            }
//            NSDictionary *fesInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"观音斋",@"V",@"7",@"P",@"1899",@"Y", nil];
//            [mla addObject:fesInfo];
//            la = [mla copy];
//        }
//    }
//
//    if (addWestFes)
//    {
//        YLDate *easterDay = nil;
//        YLDate *solarDay = [solardt nsDateValue];
//
//        //计算复活节的日期
//        int vocAreaIndex = [[SharedData sharedManager].vocationArea intValue];
//        BOOL isHKOrMAC = vocAreaIndex == 2 || vocAreaIndex == 3;
//        if ((solarDay != nil) && ([solarDay ylMonth] == 3 || [solarDay ylMonth] == 4)){
//            easterDay = [YLDate ylEasterDayOfYear:[solarDay ylYear]];
//        }
//
//        //加入复活节
//        if (easterDay) {
//            //受难日
//            if ([[solardt nsDateValue] ylIsSameDateWithDate:[easterDay ylAddDays:-2]] && isHKOrMAC) {
//                NSMutableArray *msa = [NSMutableArray arrayWithArray:sa];
//                if (msa == nil) {
//                    msa = [NSMutableArray array];
//                }
//                NSDictionary *fesInfo = @{@"V": @"受难日",
//                                          @"P": @"10",
//                                          @"Y": [NSString stringWithFormat:@"%li", (long)easterDay.ylYear]
//                                          };
//                [msa addObject:fesInfo];
//                sa = [msa copy];
//            }
//
//            //复活节
//            if ([[solardt nsDateValue] ylIsSameDateWithDate:easterDay]) {
//                NSMutableArray *msa = [NSMutableArray arrayWithArray:sa];
//                if (msa == nil) {
//                    msa = [NSMutableArray array];
//                }
//                NSDictionary *fesInfo = @{@"V": @"复活节",
//                                          @"P": isHKOrMAC ? @"10" : @"6",
//                                          @"Y": [NSString stringWithFormat:@"%li", (long)easterDay.ylYear]
//                                          };
//                [msa addObject:fesInfo];
//                sa = [msa copy];
//            }
//        }
//    }
//
//    NSMutableArray *fesA = [NSMutableArray arrayWithArray:la];
//    [fesA addObjectsFromArray:sa];
//    [fesA addObjectsFromArray:wa];
//
//    return fesA;
}

+(ExtDayInfo*) extDayInfoManager {
    static ExtDayInfo *extDayInfoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        extDayInfoManager = [ExtDayInfo new];
    });
    return extDayInfoManager;
}




//static unsigned int JXTable[] = {
//    0xD2C,0xCD2,0x2CD,0xD2C,0xCD2,0x2DD,//甲
//    0x34B,0xB34,0x4A3,0x34B,0xB34,0x4A3,//乙
//    0xD2C,0xCD2,0x2CD,0xD28,0xCD2,0x2CD,//丙
//    0x34B,0xB34,0x4B3,0x34B,0xB34,0x4B3,//丁
//    0xD2C,0xCD2,0x2CD,0xD2C,0xCD2,0x2CD,//戊
//    0x34A,0xB34,0x4B3,0x34B,0xB34,0x4B3,//己
//    0xD2C,0xCD2,0x2C5,0xD2C,0xCF2,0x2CD,//庚
//    0x34B,0xB34,0x4B2,0x34B,0xB34,0x4A3,//辛
//    0xD2C,0xCD2,0x2CD,0xD2C,0xCD2,0x2CD,//壬
//    0x34B,0xB24,0x4B3,0x34B,0xB34,0x4B3 //癸
//};
static unsigned int JXTable[] = {
    0xD2C,0x34B,0xCD2,0xB34,0x2CD,0x4B3,0xD2C,0x34B,0xCD2,0xB34,//甲子，乙丑，丙寅，丁卯，戊辰，己巳，庚午，辛未，壬申，癸酉
    0x2DD,0x4A3,0xD2C,0x34B,0xCD2,0xB34,0x2C5,0x4B2,0xD2C,0x34B,//甲戌，乙亥，丙子，丁丑，戊寅，己卯，庚辰，辛巳，壬午，癸未
    0xCD2,0xB34,0x2CD,0x4B3,0xD2C,0x34A,0xCD2,0xB34,0x2CD,0x4B3,//甲申，乙酉，丙戌，丁亥，戊子，己丑，庚寅，辛卯，壬辰，癸巳
    0xD2C,0x34B,0xCD2,0xB34,0x2CD,0x4B3,0xD2C,0x34B,0xCD2,0xB24,//甲午，乙未，丙申，丁酉，戊戌，己亥，庚子，辛丑，壬寅，癸卯
    0x2CD,0x4A3,0xD28,0x34B,0xCD2,0xB34,0x2CD,0x4A3,0xD2C,0x34B,//甲辰，乙巳，丙午，丁未，戊申，己酉，庚戌，辛亥，壬子，癸丑
    0xCD2,0xB34,0x2CD,0x4B3,0xD2C,0x34B,0xCF2,0xB34,0x2CD,0x4B3 //甲寅，乙卯，丙辰，丁巳，戊午，己未，庚申，辛酉，壬戌，癸亥
};

#pragma mark - 值神
- (NSString *)zhiShenOfMonth:(NSInteger)monthDz dayIndex:(NSInteger)dayDz {
    /**
     *  子午青龙起在申，卯酉之日又在寅。
     寅申须从子上起，巳亥在午不须论。
     唯有辰戌归辰位，丑未原从戌上寻。
     */
    NSInteger beginIndex = monthDz;
    NSInteger qinglongBeginIndex = 0;
    if (beginIndex==0||beginIndex==6) {
        qinglongBeginIndex = 8;
    }else if(beginIndex==1||beginIndex==7){
        qinglongBeginIndex = 10;
    }else if(beginIndex==2||beginIndex==8){
        qinglongBeginIndex = 0;
    }else if(beginIndex==3||beginIndex==9){
        qinglongBeginIndex = 2;
    }else if(beginIndex==4||beginIndex==10){
        qinglongBeginIndex = 4;
    }else if(beginIndex==5||beginIndex==11){
        qinglongBeginIndex = 6;
    }
    
    NSInteger ishen_12 = (dayDz-qinglongBeginIndex);
    if (ishen_12<0) {
        ishen_12+=12;
    }
    static NSArray *shiershenArr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shiershenArr = [NSArray arrayWithObjects:@"青龙",@"明堂",@"天刑",@"朱雀",@"金匮",@"天德",@"白虎",@"玉堂",@"天牢",@"玄武",@"司命",@"勾陈",nil];
    });
    
    NSString* shen_12 = [shiershenArr objectAtIndex:ishen_12];
    return shen_12;
}

-(NSArray*)getZhishenArr:(NSString*)columnName content:(NSString*)content {
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            NSString* sql = [NSString stringWithFormat:@"select * from JiShenExp where '%@' like '%%'||%@||'%%'",content,columnName];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql];
            if (!array.count) {
                sql = [NSString stringWithFormat:@"select * from XiongShenExp where '%@' like '%%'||%@||'%%'",content,columnName];
                array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql];
            }
            [self closeHuangLiDataBase];
            return array;

        }
        @catch (NSException *exception) {
            return nil;
        }
    }
}

#pragma mark - 建除12神
-(NSArray*)getJianchuArr:(NSString*)columnName content:(NSString*)content {
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            NSString* sql = [NSString stringWithFormat:@"select * from JianChuExp where '%@' like '%%'||%@||'%%'",content,columnName];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql];
            return array;
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    
}

- (NSString *)jianChuOfDate:(YLDate *)ylDate {
    NSDate *baseDate = [YLDate ylDateWithYear:1901 Month:1 Day:1 Hour:0 Minute:0 Second:0].date;
    YLDate *thisDate = [YLDate ylDateWithYear:ylDate.ylYear Month:ylDate.ylMonth Day:ylDate.ylDay Hour:0 Minute:0 Second:0];
    int jx = -1;
    
    NSArray* arr = [self twentyFourTermDaysOf:thisDate];
    if (arr.count==2) {
        int a = [[arr firstObject] intValue];
        int b = [[arr lastObject] intValue];
        int offsetDayCount = a%2==0?a/2:a/2+1;
        if (b&&a%2==0) {
            offsetDayCount+=1;
        }
        NSInteger day = [[NSCalendar gregorianCalendar] daysFromDate:baseDate toDate:thisDate.date];
        jx = (5+day-offsetDayCount)%12;
    }
    
    int jianchuIndex = 0;
    if (jx>=2) {
        jianchuIndex = jx-2;
    }else{
        jianchuIndex = jx+10;
    }
    
    static NSArray *jianchuArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jianchuArray = [@[@"建", @"除", @"满", @"平", @"定", @"执", @"破", @"危", @"成", @"收", @"开", @"闭"] copy];
    });
    
    return [jianchuArray objectAtIndex:jianchuIndex];
}

static const int MINYEAR = 1900;

-(NSArray*)twentyFourTermDaysOf:(YLDate*)solarDate{
    
    @try {
        NSInteger year = solarDate.ylYear;
        NSInteger yearOffset = year - MINYEAR;
        NSInteger offset = [self solarDayOffset:solarDate];
        
        NSInteger index = 0;
        NSInteger st = 0;//该日是否是24节气
        
        for (int i=0; i<24; i++) {
            NSInteger num = TermTable[yearOffset][i];
            if (num>offset) {
                index = i;
                st = 0;
                break;
            }else if(num==offset){
                index = i;
                st = 1;
                break;
            }
        }
        NSInteger a = index+yearOffset*24-24;//某日之前的节气数目
        NSInteger b = st;
        return @[@(a),@(b)];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

-(NSInteger) solarDayOffset:(YLDate *)d {
    
    NSInteger dayCount = 0;
    switch (d.ylMonth) {
        case 12:
            dayCount+=30;
        case 11:
            dayCount+=31;
        case 10:
            dayCount+=30;
        case 9:
            dayCount+=31;
        case 8:
            dayCount+=31;
        case 7:
            dayCount+=30;
        case 6:
            dayCount+=31;
        case 5:
            dayCount+=30;
        case 4:
            dayCount+=31;
        case 3:
            dayCount+=(LEAP(d.ylYear)?29:28);
        case 2:
            dayCount+=31;
        case 1:
            dayCount+=0;
            break;
        default:
            return -1;
    }
    return dayCount + d.ylDay - 1;
}

/*
 24节气信息表
 
 //1900-2099
 
 (0-23) -> (小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪 冬至)
 
 数字表示该节气距离1月1日的天数
 
 */

static unsigned int TermTable[200][24]={
    
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1900
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,327,341,356,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,327,341,356,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1910
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,326,341,356,
    5,19,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,
    5,19,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,355,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,//1920
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,355,
    5,20,35,50,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1930
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1940
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,65,80,95,110,125,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1950
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,50,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,//1960
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1970
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,35,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,35,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1980
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,139,155,171,186,202,218,233,249,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,235,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,109,124,140,155,171,187,202,218,234,249,266,281,296,311,326,341,355,
    4,19,34,49,63,78,94,108,123,139,155,170,186,202,217,233,248,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//1990
    
    5,19,34,49,64,79,94,108,124,139,155,171,186,202,218,233,249,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    4,19,34,48,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//2000
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    4,19,34,48,63,78,93,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2010
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,341,355,//2020
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2030
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2040
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,
    4,19,33,48,63,78,93,108,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    5,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2050
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2060
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,//2070
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,279,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,279,295,310,325,339,354,
    4,19,33,48,63,78,93,108,124,139,155,171,186,202,218,234,249,264,280,295,310,325,340,354,
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2080
    4,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,
    4,19,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2090
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,294,309,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,217,233,249,264,279,294,309,324,339,354,
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354//2099
};

#pragma mark -二十八星宿
-(NSArray*)getStar28Arr:(NSString*)columnName content:(NSString*)content{
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            NSString* sql = [NSString stringWithFormat:@"select * from StarExp where '%@' like '%%'||%@||'%%'",content,columnName];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql];
            [self closeHuangLiDataBase];
            return array;
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
}

- (NSString *)stars28OfDate:(YLDate *)date {
    // 算法来源: https://blog.csdn.net/cnbloger/article/details/4500133
    // 计算28星宿
    NSInteger B = (date.ylYear-1)*365;
    for (int i=1; i<date.ylMonth; i++) {
        int dayOfMonthI = [self dayCountOfMonth:i isLeap:NO];
        B+=dayOfMonthI;
    }
    B+=date.ylDay;
    NSInteger fixValue1 = 0;//常值为0，，切在3月1日以后(31+29+1)，则为1，其他仍然为0
    NSInteger fixValue2 = 13;//1901-1999年修正值为13，2000-2099的修正值也为13
    if (date.ylYear == 1900) { // 1900 年修正值为12 详细参见算法来源，以及百度百科: 格里历
        fixValue2 = 12;
    }
    if (date.isLeapYear) {
        if (date.ylMonth>3||(date.ylMonth==3&&date.ylDay>=1)) {
            fixValue1 = 1;
        }
    }
    NSInteger C = (date.ylYear-1)/4-fixValue2+fixValue1;
    NSInteger A = B+C;
    NSInteger index_28Stars = (A+23)%28;
    
    static NSArray *star28Arr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        star28Arr = [[NSArray arrayWithObjects:@"轸",@"角",@"亢",@"氐",@"房",@"心",@"尾",@"箕",@"斗",@"牛",@"女",@"虚",@"危",@"室",@"壁",@"奎",@"娄",@"胃",@"昴",@"毕",@"觜",@"参",@"井",@"鬼",@"柳",@"星",@"张",@"翼",nil] copy];
    });
    NSString* keyWord = [star28Arr objectAtIndex:index_28Stars];
    
    return [self get28XingXiuOfKeyWord:keyWord];
}


- (int)dayCountOfMonth:(int)month isLeap:(BOOL)isLeap{
    
    switch (month) {
        case 1:
            return 31;
            break;
        case 2:
            if (!isLeap) {
                return 28;
            }
            return 29;
            break;
        case 3:
            return 31;
            break;
        case 4:
            return 30;
            break;
        case 5:
            return 31;
            break;
        case 6:
            return 30;
            break;
        case 7:
            return 31;
            break;
        case 8:
            return 31;
            break;
        case 9:
            return 30;
            break;
        case 10:
            return 31;
            break;
        case 11:
            return 30;
            break;
        case 12:
            return 31;
            break;
        default:
            break;
    }
    return 0;
}

#pragma mark - 胎神
- (NSString *)taiShenOfMonthDiZhi:(NSString *)monthDizhi dayTgdz:(NSString *)tgdzDay {
    //1获得code
    NSInteger code = [self codeForMonthDizhi:monthDizhi];
    NSString *result = [self taiShenWithCode:code andTianGanDiZhi:tgdzDay];
    return result;
}

-(NSArray*)getTaishenArr:(NSString*)columnName content:(NSString*)content{
    
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            NSString* sql = [NSString stringWithFormat:@"select * from TaiShenExp where '%@' like '%%'||%@||'%%'",content,columnName];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql];
            return array;
        }
        @catch (NSException *exception) {
            return nil;
        }
    }

}

#pragma mark - spotlight festival
- (NSArray *) allSPFestivalData {
    @try {
        NSString *spFestivalsql = [NSString stringWithFormat:@"SELECT [_id] AS _id, [name] AS name, [description] AS descp FROM [sp_festival]"];
        [self.lock lock];
        NSArray *spFestivalResultSet = [SQLiteHelper fetchDB:db usingSQL:spFestivalsql];
        [self.lock unlock];
        if (nil != spFestivalResultSet && [spFestivalResultSet count] > 0) {
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:spFestivalResultSet.count];
            for (NSDictionary *spFestivalDict in spFestivalResultSet) {
                NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] initWithCapacity:spFestivalDict.count];
                [resultDict setObject:[spFestivalDict objectForKey:@"_id"] forKey:@"aid"];
                [resultDict setObject:[spFestivalDict objectForKey:@"name"] forKey:@"name"];
                [resultDict setObject:[spFestivalDict objectForKey:@"descp"] forKey:@"description"];
                
                [result addObject:resultDict];
            }
            NSArray *array = result.copy;
            return array;
        }

        return nil;
    } @catch (NSException *exception) {
    }
    
    return nil;
}

#pragma mark - 黄历数据库
- (void)openHuangLiDataBase {
    if (huangLidb) return;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HuangliDetails" ofType:@"db"];
    huangLidb = [SQLiteHelper openDB:path];
}

- (void)closeHuangLiDataBase {
    [SQLiteHelper close:huangLidb];
    huangLidb = nil;
}

-(NSString *)get28XingXiuOfKeyWord:(NSString *)keyWord{
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            NSString* sql5 = [NSString stringWithFormat:@"select * from StarExp where name like '%@%%'",keyWord];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql5];
            [self closeHuangLiDataBase];
            if (nil != array && [array count]>0) {
                NSDictionary *dic = array.firstObject;
                NSString* name = dic[@"name"];
                return name;
            }
            return nil;
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
}

/**
 *  @brief 获取胎神code
 *
 *  @param monthDizhi 月份地支信息
 *
 *  @return 胎神code
 */
- (NSInteger)codeForMonthDizhi:(NSString *)monthDizhi {
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            //1获得code
            NSString* sql1 = [NSString stringWithFormat:@"select * from advice where month = '%@'",monthDizhi];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql1];
            [self closeHuangLiDataBase];
            NSInteger result = 1;
            if (nil != array && [array count]>0) {
                NSDictionary *dic = array.firstObject;
                result = [dic[@"Code"] integerValue];
            }
            return result;
        }
        @catch (NSException *exception) {
            return 1;
        }
    }
    
}

- (NSString *)taiShenWithCode:(NSInteger)code andTianGanDiZhi:(NSString *)tgdzDay {
    @synchronized(self){
        @try {
            [self openHuangLiDataBase];
            //2去advices表中查询
            NSString* sql2 = [NSString stringWithFormat:@"select * from advices where Code = %ld and dayGz = '%@'",(long)code,tgdzDay];
            NSArray *array = [SQLiteHelper fetchDB:huangLidb usingSQL:sql2];
            [self closeHuangLiDataBase];
            if (nil != array && [array count]>0) {
                NSDictionary *dic = array.firstObject;
                NSString *result = dic[@"fetus"] ?: @"暂无";
                return result;
            }
            return nil;
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    
}

@end
