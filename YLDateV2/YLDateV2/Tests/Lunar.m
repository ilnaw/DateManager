/*!
 @header Lunar.m
 @abstract 日历换算
 @author Created by Jasonluo.
 @version  2012/8/11 Creation
 Copyright © 2012 YouLoft.com. All rights reserved.
 */

#import "Lunar.h"
#import "YLDate.h"
#import "ExtDateTime.h"
#import "Performance.h"

@interface Lunar(Private) {
@private
}

/*!
 @abstract 是否为有效日期
 @discussion 判断日期是否有效（1900 -2135年）
 @param date 日期
 @return YES/NO
 */
-(bool) isDateValid:(ExtDateTime*)date;
/*!
 @abstract 获取农历月每月天数偏移量数组
 @discussion 根据农历年十六进制数据以及农历年月数(是否有闰月)来计算农历月每月天数偏移量，并赋值到对应的数组中。
 @param hexData 农历年十六进制数据
 @param array 农历月每月的天数偏移量数组
 @param length 农历年月数(是否有闰月)
 */
-(void) lunarInfo:(int)hexData inArray:(int*)array length:(int)length;
/*!
 @abstract 距离某年某个节气的天数
 @discussion 给定某个节气的index和某年，计算出距离某年某个节气的天数。
 @param termIndex 某个节气
 @param year 某年
 @result 天数
 */
-(NSInteger) dayOffsetOfTerm:(NSInteger)termIndex inYear:(NSInteger)year;
/*!
 @abstract 二十四节气、天干、地支、生肖、二十八星宿、十二建除、农历月份、农历日
 @discussion 设置本地二十四节气、天干、地支、生肖、二十八星宿、十二建除、农历月份、农历日数据。
 */
-(void) loadStrArray;
@end

@implementation Lunar

static const int MINYEAR = 1900;
static const int MAXYEAR = 2135;
static unsigned int LunarTable[];
static unsigned int TermTable[236][24];

@synthesize TermStrArray,StemStrArray,BranchStrArray,MonthStrArray,DayStrArray,AnimalArray;

-(void) dealloc {
    [TermStrArray release];
    [StemStrArray release];
    [BranchStrArray release];
    [MonthStrArray release];
    [DayStrArray release];
    [AnimalArray release];
    
    [super dealloc];
}

-(id) init {
    [self loadStrArray];
    return [super init];
}

-(ExtDateTime*)lunarFromSolar:(ExtDateTime*)solar {
    ExtDateTime *lunar = [[ExtDateTime alloc] init];
    if([self isDateValid:solar]) {
        //lunar table contains information of 1 year before MINYEAR
        unsigned int hexValue = LunarTable[solar.Year-MINYEAR+1];
        unsigned int firstDay = hexValue & 0xFF;
        lunar.Year = solar.Year;
        NSInteger dayOffset =[solar solarDayOffset];
        if(firstDay > dayOffset) {
            dayOffset += 365+(LEAP(solar.Year-1)?1:0);
            hexValue = LunarTable[solar.Year-MINYEAR];
            firstDay = hexValue & 0xFF;
            lunar.Year = solar.Year-1;
        }
        unsigned int leapMonth = (hexValue >> 8) & 0xF;
        NSInteger offset = dayOffset - firstDay;
        int length = (12+((leapMonth>0)?1:0));
        int* array = (int*) malloc(sizeof(int)*length);
        [self lunarInfo:hexValue inArray:array length:length];
        
        NSInteger days = offset;
        for (int i=0; i<length; i++) {
            days -= (29+array[i]);
            if (days < 0) {
                lunar.Day = days +(29+array[i])+1;
                lunar.Month = i+1;
                if (leapMonth > 0 && i>= leapMonth) {
                    if (i == leapMonth) {
                        lunar.IsLeap = YES;
                    }
                    lunar.Month -- ;
                }
                break;
            }
        }
        free(array);
    }
    lunar.IsLunar = YES;
    lunar.Hour = solar.Hour;
    lunar.Minute = solar.Minute;
    lunar.Second = solar.Second;
    lunar.IsAllDay = solar.IsAllDay;
    return [lunar autorelease];
}
-(NSString*) lunarStrFromLunar:(ExtDateTime*)lunar {
    NSString *result = nil;
    NSString *timeStr = (lunar.IsAllDay?@"":[NSString stringWithFormat:@"%.2ld:%.2ld",(long)lunar.Hour,(long)lunar.Minute]);
    NSString *leapStr = (lunar.IsLeap?@"[闰]":@"");
    result = [NSString stringWithFormat:@"%.4ld年 %@%@ %@ %@",(long)lunar.Year,leapStr,[self.MonthStrArray objectAtIndex:lunar.Month-1],[self.DayStrArray objectAtIndex:lunar.Day-1],timeStr];
    return result;
}
-(NSString*) lunarStrOfNumMonth:(NSInteger)numMonth {
    if (numMonth > [self.MonthStrArray count]) {
        return @"";
    }
    return [self.MonthStrArray objectAtIndex:numMonth-1];
}
-(NSString*) lunarStrOfNumDay:(NSInteger)numDay {
    if (numDay > [self.DayStrArray count]) {
        return @"";
    }
    return [self.DayStrArray objectAtIndex:(numDay-1)];
}


-(ExtDateTime*)solarFromLunar:(ExtDateTime*)lunar {
    if ([self isDateValid:lunar]) {
        //lunar table contains information of 1 year before MINYEAR
        unsigned int hexValue = LunarTable[lunar.Year-MINYEAR+1];
        unsigned int firstDay = hexValue & 0xFF;
        unsigned int leapMonth = (hexValue >> 8) & 0xF;
        int length = (12+((leapMonth>0)?1:0));
        int* array = (int*) malloc(sizeof(int)*length);
        [self lunarInfo:hexValue inArray:array length:length];
        int days = firstDay;
        NSInteger end = lunar.Month + ((lunar.IsLeap || (leapMonth >0 && lunar.Month > leapMonth))?1:0)-1;
        for (int i=0; i<end; i++) {
            days += array[i]+29;
        }
        free(array);
        days+=lunar.Day-1;
        NSInteger year = lunar.Year;
        int thisYearDays = (LEAP(lunar.Year)?366:365);
        if (days >= thisYearDays) {
            days -= thisYearDays;
            year++;
        }
        ExtDateTime *solar = [ExtDateTime dateOfYear:year ByOffset:days];
        solar.Hour = lunar.Hour;
        solar.Minute = lunar.Minute;
        solar.Second = lunar.Second;
        solar.IsAllDay = lunar.IsAllDay;
        solar.IsLunar = NO;
        solar.IsLeap = NO;
        
        ExtDateTime *verify = [self lunarFromSolar:solar];
        if (verify.Year == lunar.Year && verify.Month == lunar.Month && verify.Day == lunar.Day) {
            return solar;
        }
        return nil;
    }    
    return nil;
}

-(NSInteger) termIndexOfDate:(ExtDateTime*)date {
    if([self isDateValid:date]){
        int dayOffset = (int)[date solarDayOffset];
        return indexOfElement((const int*)TermTable[(date.Year-MINYEAR)], dayOffset, 24);
    }
    return -1;
}
-(NSString*) termStrOfIndex:(NSInteger)index {
    if (index > -1) {
        return [TermStrArray objectAtIndex:index];
    }
    return nil;
}
-(ExtDateTime*) termTimeOfIndex:(NSInteger)index inYear:(NSInteger)year {
    if (index > -1 && index < 24 && year < MAXYEAR && year >= MINYEAR) {
        int seconds = TermTimeTable[year-MINYEAR][index];
        YLDate *dt = [YLDate ylDateWithYear:1900 Month:1 Day:1 Hour:0 Minute:0 Second:0];
        NSDate *dt2 = [NSDate dateWithTimeInterval:seconds sinceDate:dt.date];
        ExtDateTime *edt = [ExtDateTime dateTimeWithNSDate:[YLDate ylDateWithDate:dt2]];
        return edt;
    }
    return nil;
}

-(NSInteger) termIndexBeforeDate:(ExtDateTime*)date {
    if([self isDateValid:date]){
        int dayOffset = (int)[date solarDayOffset];
        int* data = (int*) malloc(sizeof(int)*25);
        const int* table = (const int*)TermTable[(date.Year-MINYEAR)];
        int index = indexOfElement(table, dayOffset, 24);
        if (index > -1) {
            free(data);
            return index; 
        }
        memcpy(data, table, 24*sizeof(int));
        data[24] = dayOffset;
        bubleSort(data, 25, NO);
        index = indexOfElement(data, dayOffset, 25);
        free(data);
        return index-1;
    }
    return -1;
}

-(ExtDateTime*)dateOfTerm:(NSInteger)termIndex inYear:(NSInteger)year {
    if(year > MINYEAR && year < MAXYEAR && termIndex >-1 && termIndex < 24) {
        return [ExtDateTime dateOfYear:year ByOffset:[self dayOffsetOfTerm:termIndex inYear:year]];
    }
    return nil;
}

-(NSString*) stemBranchStrOfIndex:(NSInteger)index {
    if (index > -1) {
        return [NSString stringWithFormat:@"%@%@",[StemStrArray objectAtIndex:index%10],
                [BranchStrArray objectAtIndex:index%12]];
    }
    return nil;
}

-(NSInteger) stemBranchYearOfSolarDate:(ExtDateTime*)solar {
    int t=0;
    int b=0;
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        NSInteger yearOffset = (solar.Year - referenceDate.Year);
        if ([self dayOffsetOfTerm:2 inYear:solar.Year] > [solar solarDayOffset]) {
            yearOffset -=1; 
        }
        t = (yearOffset+5)%10;
        b = (yearOffset+11)%12;
    }
    return ((6*t-5*b)+60)%60;
}


-(NSInteger) animalIndexOfSolarDate:(ExtDateTime*)solar {
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        // 4.5.4 hyd 修改生肖划分逻辑：之前的逻辑以立春为节点，现修改为每年的农历一月初一为节点
        // 把选中的日期转化为农历
        ExtDateTime *lunarYear = [self lunarFromSolar:solar];
        NSInteger yearOffset = (lunarYear.Year - referenceDate.Year);
        return (yearOffset+11)%12;
    }
    return -1;
}
-(NSString*) animalStrOfIndex:(NSInteger)index {
    if (index > -1) {
        return [AnimalArray objectAtIndex:index];
    }
    return nil;
}
-(NSString*) animalStrOfSolarDate:(ExtDateTime*)solar {
    NSInteger index = [self animalIndexOfSolarDate:solar];
    return ([self animalStrOfIndex:index]);
}

-(NSInteger) stemBranchMonthOfSolarDate:(ExtDateTime*)solar {
    int t=0;
    int b=0;
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        NSInteger monthOffset = (solar.Year - referenceDate.Year)*12+(([self termIndexBeforeDate:solar]+2)/2) -2;
        t = (monthOffset+2)%10;
        b = (monthOffset+2)%12;
    }
    return ((6*t-5*b)+60)%60;
}

-(NSInteger) stemBranchDayOfSolarDate:(ExtDateTime*)solar {
    int t=0;
    int b=0;
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        NSInteger dayOffset = [solar solarDayIntervalSinceDate:referenceDate];
        t = (dayOffset+9)%10;
        b = (dayOffset+3)%12;
    }
    return ((6*t-5*b)+60)%60;
}
-(NSInteger) stemBranchHourOfSolarDate:(ExtDateTime*)solar {
    NSInteger t = [self stemDayOfSolarDate:solar];
    if (t<0) {
        return 0;
    }
    YLDate *solardt = [solar nsDateValue];
    if (solar.Hour >= 23) {
        ExtDateTime *newSolar =[ExtDateTime dateTimeWithNSDate:[solardt ylAddDays:1]];
        t = [self stemDayOfSolarDate:newSolar];
    }
    NSInteger b = [solardt ylChineseNumHour];
    int newT = (b+((t>4)?(t-5):t)*2)%10;
    return ((6*newT-5*b)+60)%60;
}

-(NSInteger) stemDayOfSolarDate:(ExtDateTime*)solar {
    int t=0;
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        NSInteger dayOffset = [solar solarDayIntervalSinceDate:referenceDate];
        t = (dayOffset+9)%10;
    }
    return t;
}
-(NSInteger) branchDayOfSolarDate:(ExtDateTime*)solar {
    int b=0;
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        NSInteger dayOffset = [solar solarDayIntervalSinceDate:referenceDate];
        b = (dayOffset+3)%12;
    }
    return b;
}


-(StemAndBranch)stemBranchOfSolarDate:(ExtDateTime*)solar {
    // 1899-02-04: 猪(11) 己亥(05 11)　丙寅(02 02)　癸卯(09 03)
    StemAndBranch sb;
    sb.AnimalIndex = -1;
    sb.Year = -1;
    sb.Month = -1;
    sb.Day = -1;
    if ([self isDateValid:solar]) {
        ExtDateTime *referenceDate = [ExtDateTime dateTimeWithNumDate:19000305 numTime:0];
        NSInteger yearOffset = (solar.Year - referenceDate.Year);
        NSInteger termIndex = [self termIndexBeforeDate:solar];
        NSInteger monthOffset = yearOffset*12+((termIndex+2)/2) -2;
        NSInteger dayOffset = [solar solarDayIntervalSinceDate:referenceDate];
        if ([self dayOffsetOfTerm:2 inYear:solar.Year] > [solar solarDayOffset]) {
            yearOffset -=1; 
        }
        //((6*t-5*b)+60)%60;
        sb.AnimalIndex = (yearOffset+11)%12;
        sb.Year = ((6*((yearOffset+5)%10)-5*((yearOffset+11)%12))+60)%60;
        sb.Month = ((6*((monthOffset+2)%10)-5*((monthOffset+2)%12))+60)%60;
        sb.Day = ((6*((dayOffset+9)%10)-5*((dayOffset+3)%12))+60)%60;
    }
    return sb;
}
-(NSString*) stemBranchStrOfSolarDate:(ExtDateTime*)solar {
    StemAndBranch sb = [self stemBranchOfSolarDate:solar];
    NSString *result = [NSString stringWithFormat:@"%@%@[%@] %@%@ %@%@",
                        [StemStrArray objectAtIndex:sb.Year%10],[BranchStrArray objectAtIndex:sb.Year%12],
                        [AnimalArray objectAtIndex:sb.AnimalIndex],
                        [StemStrArray objectAtIndex:sb.Month%10],[BranchStrArray objectAtIndex:sb.Month%12],
                        [StemStrArray objectAtIndex:sb.Day%10],[BranchStrArray objectAtIndex:sb.Day%12]];
    return result;
}

-(NSString*) lunarHourStr:(NSInteger)index {
    if (index >-1 && index < 12) {
        return [BranchStrArray objectAtIndex:index];
    }
    return nil;
}
-(NSString*) chineseHourRangeStr:(NSInteger)index {
    switch (index) {
		case 0:
			return @"23:00 - 01:00";
		case 1:
			return @"01:00 - 03:00";
		case 2:
			return @"03:00 - 05:00";
		case 3:
			return @"05:00 - 07:00";
		case 4:
			return @"07:00 - 09:00";
		case 5:
			return @"09:00 - 11:00";
		case 6:
			return @"11:00 - 13:00";
		case 7:
			return @"13:00 - 15:00";
		case 8:
			return @"15:00 - 17:00";
		case 9:
			return @"17:00 - 19:00";
		case 10:
			return @"19:00 - 21:00";
		case 11:
			return @"21:00 - 23:00";
		default:
			return @"N/A";
			break;
	}
}


-(NSArray*) hotDurationsOfSolarYear:(NSInteger)year {
    ExtDateTime *term1Date = [self dateOfTerm:11 inYear:year];
    NSInteger baseDay = [self stemDayOfSolarDate:term1Date];
    YLDate *firstDate = [[term1Date nsDateValue] ylAddDays:(20 + ((baseDay>6)?(16-baseDay):(6-baseDay)))];
    YLDate *secondDate = [firstDate ylAddDays:10];

    ExtDateTime *term2Date = [self dateOfTerm:14 inYear:year];
    NSInteger baseDay2 = [self stemDayOfSolarDate:term2Date];
    
    YLDate *thirdDate = [[term2Date nsDateValue] ylAddDays:((baseDay2>6)?(16-baseDay2):(6-baseDay2))];
    return [NSArray arrayWithObjects:firstDate,secondDate,thirdDate, nil];
}
-(NSString*) hotDayStrOfDate:(YLDate *)date hotDays:(NSArray*)hotDays {
    return [self hotDayStrOfDate:date
                         hotDays:hotDays
                           index:NULL];
}

- (NSString *)hotDayStrOfDate:(YLDate *)date
                      hotDays:(NSArray *)hotDays
                        index:(NSInteger *)index {
    if (index) { *index = -1; }
    if (nil == hotDays || 3 != [hotDays count]) {
        return nil;
    }
    NSString *resultStr = nil;
    if (hotDays) {
        NSInteger interval1 = [date ylDaysSinceDate:[hotDays objectAtIndex:0]];
        NSInteger interval2 = [date ylDaysSinceDate:[hotDays objectAtIndex:1]];
        NSInteger interval3 = [date ylDaysSinceDate:[hotDays objectAtIndex:2]];
        
        if (interval1 >= 0 && interval2 < 0) {
            if (index) { *index = interval1+1; }
            resultStr = [NSString stringWithFormat:@"初伏第%ld天",(long)(interval1+1)];
        }
        else if (interval2 >=0 && interval3 < 0) {
            if (index) { *index = interval2+1; }
            resultStr = [NSString stringWithFormat:@"中伏第%ld天",(long)interval2+1];
        }
        else if (interval3 >= 0 && interval3 < 10) {
            if (index) { *index = interval3+1; }
            resultStr = [NSString stringWithFormat:@"末伏第%ld天",(long)interval3+1];
        }
    }
    return resultStr;
}

-(YLDate *) coldBeginDateOfSolarYear:(NSInteger)year {
    ExtDateTime *dt = [self dateOfTerm:23 inYear:year];
    YLDate *date = [dt nsDateValue];
    return date;
}

-(NSString*) coldDayStrOfDate:(YLDate *)date coldBeginDate:(YLDate *)coldBegin{
    return [self coldDayStrOfDate:date
                    coldBeginDate:coldBegin
                            index:NULL];
}

- (NSString *)coldDayStrOfDate:(YLDate *)date
                 coldBeginDate:(YLDate *)coldBegin
                         index:(NSInteger *)index {
    NSInteger daysInterval = [date ylDaysSinceDate:coldBegin];
    if (daysInterval >= 0) {
        NSInteger section = (daysInterval / 9);
        NSInteger row = (daysInterval % 9 + 1);
        if (section >= 0 && section <= 8) {
            if (index) { *index = row; }
        } else {
            if (index) { *index = -1; }
        }
        switch (section) {
            case 0:
                return [NSString stringWithFormat:@"一九第%ld天",(long)row];
            case 1:
                return [NSString stringWithFormat:@"二九第%ld天",(long)row];
            case 2:
                return [NSString stringWithFormat:@"三九第%ld天",(long)row];
            case 3:
                return [NSString stringWithFormat:@"四九第%ld天",(long)row];
            case 4:
                return [NSString stringWithFormat:@"五九第%ld天",(long)row];
            case 5:
                return [NSString stringWithFormat:@"六九第%ld天",(long)row];
            case 6:
                return [NSString stringWithFormat:@"七九第%ld天",(long)row];
            case 7:
                return [NSString stringWithFormat:@"八九第%ld天",(long)row];
            case 8:
                return [NSString stringWithFormat:@"九九第%ld天",(long)row];
            default:
                return nil;
        }
    }
    return nil;
}

-(NSInteger) lunarMaxDayOfMonth:(NSInteger)month inYear:(NSInteger)year isLeap:(BOOL)isleap {
    unsigned int hexValue = LunarTable[year-MINYEAR+1];
    unsigned int leapMonth = (hexValue >> 8) & 0xF;
    if (leapMonth >0 && isleap) {
        return 29+((hexValue>>12)&0x1);
    }
    else {
        return 29+((hexValue>>(24-month+1))&0x1);
    }
}
-(NSInteger) lunarLeapMonthOfYear:(NSInteger)year {
    unsigned int hexValue = LunarTable[year-MINYEAR+1];
    unsigned int leapMonth = (hexValue >> 8) & 0xF;
    return leapMonth;
}


-(bool) isDateValid:(ExtDateTime*)date {
    if(((date.IsLunar && date.Year >= MINYEAR-1) || (!date.IsLunar && date.Year >= MINYEAR)) && 
       date.Year <=MAXYEAR && date.Month >0 && date.Month<13 &&
       date.Day >0 && date.Hour >-1 && date.Hour <24 && date.Minute >-1 && date.Minute <60 &&
       date.Second >-1 && date.Second <60){
        if(date.IsLunar||(!date.IsLunar && date.Day<=[date solarDayCountInMonth])){
            return YES;
        }
    }
    return NO;
}
-(NSInteger) dayOffsetOfTerm:(NSInteger)termIndex inYear:(NSInteger)year {
    if(year >= MINYEAR && year <= MAXYEAR && termIndex >-1 && termIndex < 24) {
        return TermTable[(year-MINYEAR)][termIndex];
    }
    return -1;
}


-(void) lunarInfo:(int)hexData inArray:(int*)array length:(int)length {
    unsigned int leapMonth = (hexData >> 8) & 0xF;
    for (int i=0; i<length; i++) {
        unsigned int value = 0;
        if (leapMonth >0 && i >= leapMonth) {
            if (i==leapMonth) {
                value = (hexData >> 12) & 0x1;
            }
            else {
                value = (hexData >> (24-i+1)) & 0x1;
            }
        }
        else {
            value = (hexData >> (24-i)) & 0x1;
        }
        array[i]=value;
    }
}

-(void) loadStrArray {
    self.TermStrArray =[NSArray arrayWithObjects:@"小寒",@"大寒",@"立春",@"雨水",@"惊蛰",@"春分",@"清明",@"谷雨",@"立夏",@"小满",@"芒种",@"夏至",@"小暑",@"大暑",@"立秋",@"处暑",@"白露",@"秋分",@"寒露",@"霜降",@"立冬",@"小雪",@"大雪",@"冬至",nil];
    self.StemStrArray = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸",nil];
    self.BranchStrArray = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
    
    self.MonthStrArray = [NSArray arrayWithObjects:@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",
                     @"七月",@"八月",@"九月",@"十月",@"冬月",@"腊月",nil];
    self.DayStrArray = [NSArray arrayWithObjects:@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",
                   @"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",
                   @"十九",@"二十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    self.AnimalArray = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
}

#pragma Datas

/*
    甲子、乙丑，配海中金； 丙寅、丁卯，配炉中火； 戊辰、己巳，配大林木； 
 　　庚午、辛未，配路旁土； 壬申、癸酉，配剑锋金； 甲戌、乙亥，配山头火； 
 　　丙子、丁丑，配洞下水； 戊寅、己卯，配城墙土； 庚辰、辛巳，配白蜡金； 
 　　壬午、癸未，配杨柳木； 甲申、乙酉，配泉中水； 丙戌、丁亥，配屋上土； 
 　　戊子、己丑，配霹雷火； 庚寅、辛卯，配松柏木； 壬辰、癸巳，配常流水； 
 　　甲午、乙未，配沙中金； 丙申、丁酉，配山下火； 戊戌、己亥，配平地木； 
 　　庚子、辛丑，配壁上土； 壬寅、癸卯，配金箔金； 甲辰、乙巳，配佛灯火； 
 　　丙午、丁未，配天河水； 戊申、己酉，配大驿土； 庚戌、辛亥，配钗钏金； 
 　　壬子、癸丑，配桑松木； 甲寅、乙卯，配大溪水； 丙辰、丁巳，配沙中土； 
 　　戊午、己未，配天上火； 庚申、辛酉，配石榴木； 壬戌、癸亥，配大海水。
 */

/*
     甲己 乙庚 丙辛 丁壬 戊癸
 子  甲子 丙子 戊子 庚子 壬子
 丑  乙丑 丁丑 己丑 辛丑 癸丑
 寅  丙寅 戊寅 庚寅 壬寅 甲寅
 卯  丁卯 己卯 辛卯 癸卯 乙卯
 辰  戊辰 庚辰 壬辰 甲辰 丙辰
 巳  己巳 辛巳 癸巳 乙巳 丁巳
 午  庚午 壬午 甲午 丙午 戊午
 未  辛未 癸未 乙未 丁未 己未 
 申  壬申 甲申 丙申 戊申 庚申
 酉  癸酉 乙酉 丁酉 己酉 辛酉
 戌  甲戌 丙戌 戊戌 庚戌 壬戌
 亥  乙亥 丁亥 己亥 辛亥 癸亥
 */


/*!
 1899~2135年 农历信息
 eg:2012年 -> 0x1754416 -> (0001 0111 0101 0100 0100 0001 0110)2
 
 从后往前读8位 表示 正月初一 距离 公历1月1日 的天数: (0001 0110)2 -> 22 天
 继续往前读4位 表示 闰哪个月 (0100)2 -> 4 即 闰四月 （0表示该年没有闰月）
 继续往前读13位 表示 每月天数信息 其中前12位表示正月到腊月的天数信息 第13位表示闰月的天数信息 (1 0111 0101 0100)2 -> 正月大、二月小、三月大 。。。腊月小、闰四月小
 
 注:农历月大30天 月小29天
 */

static unsigned int LunarTable[] = {
    0x156A028,0x97A81E,0x95C031,0x14AE026,0xA9A51C,0x1A4C02E,0x1B2A022,0xCAB418,0xAD402B,0x135A020,     //1899-1908
    0xABA215,0x95C028,0x14B661D,0x149A030,0x1A4A024,0x1A4B519,0x16A802C,0x1AD4021,0x15B4216,0x12B6029,  //1909-1918
    0x92F71F,0x92E032,0x1496026,0x169651B,0xD4A02E,0xDA8023,0x156B417,0x56C02B,0x12AE020,0xA5E216,      //1919-1928
    0x92E028,0xCAC61D,0x1A9402F,0x1D4A024,0xD53519,0xB5A02C,0x56C022,0x10DD317,0x125C029,0x191B71E,     //1929-1938
    0x192A031,0x1A94026,0x1B1561A,0x16AA02D,0xAD4023,0x14B7418,0x4BA02B,0x125A020,0x1A56215,0x152A028,  //1939-1948
    0x16AA71C,0xD9402F,0x16AA024,0xA6B51A,0x9B402C,0x14B6021,0x8AF317,0xA5602A,0x153481E,0x1D2A030,     //1949-1958
    0xD54026,0x15D461B,0x156A02D,0x96C023,0x155C418,0x14AE02B,0xA4C020,0x1E4C314,0x1B2A027,0xB6A71D,    //1959-1968
    0xAD402F,0x12DA024,0x9BA51A,0x95A02D,0x149A021,0x1A9A416,0x1A4A029,0x1AAA81E,0x16A8030,0x16D4025,   //1969-1978
    0x12B561B,0x12B602E,0x936023,0x152E418,0x149602B,0x164EA20,0xD4A032,0xDA8027,0x15E861C,0x156C02F,   //1979-1988
    0x12AE024,0x95E51A,0x92E02D,0xC96022,0xE94316,0x1D4A028,0xD6A81E,0xB58031,0x156C025,0x12DA51B,      //1989-1998
    0x125C02E,0x192C023,0x1B2A417,0x1A9402A,0x1B4A01F,0xEAA215,0xAD4027,0x157671C,0x4BA030,0x125A025,   //1999-2008
    0x1956519,0x152A02C,0x1694021,0x1754416,0x15AA028,0xABA91E,0x974031,0x14B6026,0xA2F61B,0xA5602E,    //2009-2018
    0x1526023,0xF2A418,0xD5402A,0x15AA01F,0xB6A215,0x96C028,0x14DC61C,0x149C02F,0x1A4C024,0x1D4C519,    //2019-2028
    0x1AA602B,0xB54021,0xED4316,0x12DA029,0x95EB1E,0x95A031,0x149A026,0x1A1761B,0x1A4A02D,0x1AA4022,    //2029-2038
    0x1BA8517,0x16B402A,0xADA01F,0xAB6215,0x936028,0x14AE71D,0x149602F,0x154A024,0x164B519,0xDA402C,    //2039-2048
    0x15B4020,0x96D316,0x126E029,0x93E81F,0x92E031,0xC96026,0xD1561B,0x1D4A02D,0xD64022,0x14D9417,      //2049-2058
    0x155C02A,0x125C020,0x1A5C314,0x192C027,0x1AAA71C,0x1A9402F,0x1B4A023,0xBAA519,0xAD402C,0x14DA021,  //2059-2068
    0xABA416,0xA5A029,0x153681E,0x152A031,0x1694025,0x16D461A,0x15AA02D,0xAB4023,0x1574417,0x14B602A,   //2069-2078
    0xA56020,0x164E315,0xD26027,0xE6671C,0xD5402F,0x15AA024,0x96B519,0x96C02C,0x14AE021,0xA9C417,       //2079-2088
    0x1A4C028,0x1D2C81D,0x1AA4030,0x1B54025,0xD5561A,0xADA02D,0x95C023,0x153A418,0x149A02A,0x1A2A01F,   //2089-2098
    0x1E4A214,0x1AA4027,0x1B6471C,0x16B402F,0xABA025,0x9B651B,0x93602D,0x1496022,0x1A96417,0x154A02A,   //2099-2108
    0x16AA91E,0xDA4031,0x15AC026,0xAEC61C,0x126E02E,0x92E024,0xD2E419,0xA9602C,0xD4A020,0xF4A315,       //2109-2118
    0xD54028,0x155571D,0x155A02F,0xA5C025,0x195C51A,0x152C02D,0x1A94021,0x1C95416,0x1B2A029,0xB5A91F,   //2119-2128
    0xAD4031,0x14DA026,0xA3B61C,0xA5A02F,0x151A023,0x1A2B518,0x165402B};                                //2129-2135

/*!
 24节气信息表
 
 (0-23) -> (小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪 冬至)
 
 数字表示该节气距离1月1日的天数
 
 Updated:2015-05-05
 
 */
static unsigned int TermTable[236][24]={//1900-2135
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1900
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1901
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,//1902
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1903
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,327,341,356,//1904
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1905
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1906
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1907
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,327,341,356,//1908
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1909
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1910
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1911
    6,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,282,297,312,326,341,356,//1912
    5,19,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1913
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1914
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1915
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,//1916
    5,19,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1917
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,355,//1918
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1919
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,//1920
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,//1921
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,355,//1922
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1923
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,297,312,326,341,356,//1924
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,//1925
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1926
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1927
    5,20,35,50,65,80,95,110,126,141,157,173,188,204,220,235,251,266,281,296,311,326,341,356,//1928
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1929
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1930
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,//1931
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1932
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1933
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1934
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1935
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1936
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1937
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1938
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1939
    5,20,35,50,65,80,95,110,126,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1940
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1941
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1942
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1943
    5,20,35,50,65,80,95,110,125,141,157,172,188,204,220,235,251,266,281,296,311,326,341,356,//1944
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//1945
    5,19,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1946
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1947
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1948
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//1949
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1950
    5,20,34,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1951
    5,20,35,50,64,80,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1952
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//1953
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,340,355,//1954
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1955
    5,20,35,50,64,79,95,110,125,141,157,172,188,204,219,235,251,266,281,296,311,326,341,356,//1956
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//1957
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1958
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1959
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,//1960
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//1961
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1962
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1963
    5,20,35,49,64,79,95,110,125,141,157,172,188,204,219,235,250,266,281,296,311,326,341,356,//1964
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//1965
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1966
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1967
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1968
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//1969
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1970
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1971
    5,20,35,49,64,79,95,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1972
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//1973
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1974
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1975
    5,20,35,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1976
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//1977
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,//1978
    5,19,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1979
    5,20,35,49,64,79,94,110,125,141,156,172,188,204,219,235,250,266,281,296,311,326,341,356,//1980
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//1981
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//1982
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//1983
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,//1984
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//1985
    4,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//1986
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,235,250,265,281,296,311,326,340,355,//1987
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1988
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,//1989
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//1990
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1991
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1992
    4,19,34,48,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,//1993
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//1994
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1995
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//1996
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//1997
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//1998
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//1999
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//2000
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2001
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2002
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2003
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//2004
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2005
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2006
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2007
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//2008
    4,19,34,48,63,78,93,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2009
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2010
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,//2011
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//2012
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2013
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2014
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,325,340,355,//2015
    5,19,34,49,64,79,94,109,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//2016
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2017
    4,19,34,49,63,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2018
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2019
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,341,355,//2020
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2021
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,//2022
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2023
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2024
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2025
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2026
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2027
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2028
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2029
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2030
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2031
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2032
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2033
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2034
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2035
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2036
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2037
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2038
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2039
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2040
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,//2041
    4,19,34,48,63,78,93,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2042
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2043
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,//2044
    4,19,33,48,63,78,93,108,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,//2045
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2046
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2047
    5,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2048
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,//2049
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2050
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,//2051
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2052
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,//2053
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2054
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2055
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2056
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2057
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2058
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2059
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2060
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2061
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2062
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2063
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,310,325,340,355,//2064
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2065
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2066
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2067
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2068
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2069
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,//2070
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2071
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2072
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,279,295,310,325,339,354,//2073
    4,19,33,48,63,78,93,109,124,139,155,171,187,202,218,234,249,264,280,295,310,325,340,354,//2074
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2075
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2076
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,279,295,310,325,339,354,//2077
    4,19,33,48,63,78,93,108,124,139,155,171,186,202,218,234,249,264,280,295,310,325,340,354,//2078
    4,19,34,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2079
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2080
    4,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,//2081
    4,19,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,//2082
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2083
    4,19,34,49,63,78,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,//2084
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,//2085
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,340,354,//2086
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2087
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2088
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,295,310,324,339,354,//2089
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2090
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2091
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2092
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,218,233,249,264,279,294,309,324,339,354,//2093
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2094
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2095
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2096
    3,18,33,48,63,78,93,108,124,139,155,170,186,202,217,233,249,264,279,294,309,324,339,354,//2097
    4,18,33,48,63,78,93,108,124,139,155,171,186,202,218,233,249,264,280,295,310,325,339,354,//2098
    4,19,33,48,63,78,93,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,354,//2099
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2100
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2101
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2102
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//2103
    5,20,35,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,//2104
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2105
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,280,296,311,326,340,355,//2106
    5,20,34,49,64,79,94,110,125,140,156,172,187,203,219,235,250,265,281,296,311,326,341,355,//2107
    5,20,35,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,//2108
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2109
    5,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,326,340,355,//2110
    5,20,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,341,355,//2111
    5,20,35,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,//2112
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,249,265,280,295,310,325,340,355,//2113
    5,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2114
    5,20,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,341,355,//2115
    5,20,35,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,//2116
    4,19,34,49,63,79,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2117
    5,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,296,311,325,340,355,//2118
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,341,355,//2119
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,356,//2120
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2121
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,219,234,250,265,280,295,311,325,340,355,//2122
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2123
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//2124
    4,19,34,49,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2125
    4,19,34,49,64,79,94,109,125,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2126
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2127
    5,20,34,49,64,79,94,110,125,141,156,172,188,203,219,235,250,266,281,296,311,326,341,355,//2128
    4,19,34,48,63,78,94,109,124,140,155,171,187,203,218,234,249,265,280,295,310,325,340,355,//2129
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2130
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355,//2131
    5,20,34,49,64,79,94,110,125,140,156,172,188,203,219,235,250,265,281,296,311,326,341,355,//2132
    4,19,34,48,63,78,94,109,124,140,155,171,187,202,218,234,249,265,280,295,310,325,340,355,//2133
    4,19,34,49,64,79,94,109,124,140,156,171,187,203,218,234,250,265,280,295,310,325,340,355,//2134
    5,19,34,49,64,79,94,109,125,140,156,172,187,203,219,234,250,265,281,296,311,326,340,355 //2135
   };

/*!
 24节气时间表
 
 (0-23) -> (小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪 冬至)
 
 数字表示该节气距离当日00:00:00的秒数
 
 */
static unsigned int TermTimeTable[236][24]={//1900-2135
    0,0,49891,36074,30112,34741,49961,77226,28512,76615,45535,20385,83408,59767,31834,83989,40598,73211,7989,17716,16784,6470,75350,52894,//1900
    28403,4588,70792,56694,51053,55415,71061,11606,49824,11079,66987,41266,18454,80625,53166,18449,61815,7736,29188,38774,38069,27673,10357,74195,
    49893,25916,5890,77982,72452,76593,5846,32648,70728,32011,1187,62108,38779,14992,73336,39183,81985,28520,49510,59738,58666,48923,31261,9331,
    71023,47612,27077,13248,7132,11686,26753,53919,5122,53101,22027,83095,59796,35925,8150,60095,16941,49421,70904,80583,80003,69684,52519,30025,
    5822,68271,48247,33891,28299,32314,47931,74528,26314,73735,43258,17481,81101,56975,29511,81384,38278,70812,5734,15542,14698,4553,73520,51236,
    26826,3116,69349,55258,49536,53851,69268,9825,47644,9076,64413,39082,15599,78337,50217,16116,58906,5396,26376,36475,35386,25493,7847,72221,
    47607,24194,3834,76467,70566,75167,4036,31150,68909,30295,85734,60108,36916,12752,71494,36812,80172,26099,47693,57283,56814,46431,29365,6796,
    69085,45047,25129,10698,5225,9179,24887,51433,3215,50594,19976,80579,57550,33476,5758,57803,14522,47332,68562,78690,77777,67923,50366,28292,
    3667,66484,46033,32034,26014,30434,45586,72675,23900,71886,40743,15541,78480,54845,26802,79019,35536,68295,3051,13007,12121,2077,71017,48804,
    24313,655,66751,52699,46847,51176,66565,7064,45050,6292,62036,36331,13437,75626,48148,13410,56795,2669,24188,33750,33183,22815,5689,69587,
    45477,21536,1642,73687,68190,72172,1375,27942,65960,27008,82580,56921,33662,9776,68228,34040,76930,23444,44465,54668,53603,43850,26213,4303,//1910
    66052,42683,22216,8416,2330,6860,21872,48955,18,47913,16672,77730,54295,30516,2665,54777,11596,44250,65696,75491,74820,64553,47254,24789,
    449,62946,42811,28534,22859,26959,42495,69141,20823,68226,37649,11811,75402,51220,23830,75679,32739,65279,402,10200,9518,85688,68333,45879,
    21474,83944,63758,49452,43738,47875,63351,3771,41679,2991,58404,32966,9532,72221,44147,10089,52944,85961,20620,30889,29862,20112,2461,66891,
    42171,18709,84556,70674,64548,69042,84110,24792,62403,23858,79196,53700,30432,6412,65111,30574,73946,20027,41687,51436,51061,40821,23825,1342,
    63616,39570,19526,4983,85696,3074,18555,44926,82964,43823,13207,73760,50865,26781,85661,51298,8225,41025,62452,72579,71858,62006,44633,22544,
    84467,60813,40438,26279,20241,24410,39469,66275,17385,65150,33939,8661,71613,48068,20095,72511,29099,62083,83271,7031,6135,82664,65169,43109,
    18567,81438,61052,47084,41088,45431,60594,1042,38742,86311,55390,29656,6613,68865,41407,6818,50361,82806,18128,27817,27414,17092,59,63937,
    39863,15872,82385,67961,62455,66337,81912,21923,59891,20727,76257,50374,27127,3083,61644,27427,70526,17137,38417,48767,47932,38282,20789,85287,
    60688,37240,16763,2845,83129,1145,16124,43115,80520,41944,10596,71610,48030,24266,82681,48496,5257,38118,59600,69674,69090,59107,41867,19621,
    81647,57860,37586,23337,17462,21555,36894,63547,15077,62503,31822,5985,69516,45293,17894,69675,26792,59285,80948,4359,3894,80123,63016,40616,//1920
    16420,78879,58812,44396,38709,42658,58121,84734,36257,83800,52885,27335,3994,66615,38605,4507,47379,80382,15036,25335,24330,14667,83485,61643,
    37015,13674,79584,65769,59629,64113,79080,19712,57170,18613,73815,48399,25045,1178,59828,25449,68779,14972,36565,46372,45912,35709,18638,82612,
    58440,34485,14417,86380,80666,84522,13547,39933,77894,38713,8058,68562,45731,21629,80669,46305,3429,36210,57802,67849,67220,57216,39873,17593,
    79533,55701,35372,21076,15132,19205,34387,61113,12339,60025,28891,3558,66564,43047,15134,67673,24330,57493,78729,2662,1751,78382,60779,38724,
    13994,76808,56205,42179,35990,40326,55347,82265,33471,81173,50182,24594,1494,63887,36425,1985,45601,78199,13642,23462,23173,12924,82337,59795,
    35657,11545,77896,63283,57581,61268,76697,16563,54500,15266,70897,44998,21936,84284,56652,22434,65751,12392,33891,44294,43662,34053,16719,81198,
    56677,33108,12602,84853,78616,82742,11166,37898,75184,36467,5085,66127,42595,19001,77483,43523,325,33412,54905,65197,64614,54835,37578,15506,
    77471,53796,33382,19152,13034,17051,32071,58600,9809,57139,26229,383,63855,39733,12450,64385,21705,54326,76191,86068,85770,75612,58636,36216,
    12121,74530,54523,40008,34317,38085,53473,79815,31220,78453,47447,21633,84698,60794,32921,85272,41974,75135,10022,20484,19647,10083,78984,57161,
    32552,9176,75067,61185,54993,59382,74242,14745,52019,13319,68282,42765,19180,81713,53818,19577,62902,9352,31048,41157,40812,30865,13837,77969,//1930
    53735,29847,9638,81614,75726,79574,8426,34785,72575,33321,2505,62880,39934,15680,74692,40213,83835,30195,52011,62126,61791,51878,34815,12571,
    74703,50805,30560,16099,10159,14012,29179,55681,6908,54393,23263,84154,60735,37079,9108,61570,18172,51349,72578,83030,82180,72605,55102,33252,
    8600,71559,50956,36975,30684,34983,49829,76694,27705,75405,44239,18705,81857,57922,30330,82339,39446,72066,7433,17283,16978,6804,76265,53846,
    29787,5811,72217,57697,51980,55673,71019,10807,48644,9291,64881,38871,15865,78127,50618,16320,59768,6308,27899,38175,37601,27860,10591,74962,
    50539,26897,6521,78716,72610,76663,5181,31804,69122,30287,85295,59871,36332,12774,71268,37436,80644,27487,48940,59349,58651,48922,31490,9423,
    71197,47533,26956,12780,6546,10668,25604,52264,3390,50844,19840,80494,57498,33470,6190,58228,15635,48354,70345,80282,80078,69900,52933,30397,
    6224,68457,48333,33641,27864,31501,46882,73148,24635,71827,40968,15116,78355,54413,26720,79069,35963,69174,4254,14790,14115,4587,73576,51696,
    27068,3522,69298,55173,48826,52982,67719,8081,45309,6608,61597,36212,12681,75422,47561,13546,56888,3567,25284,35624,35299,25562,8518,72801,
    48471,24640,4226,76155,69971,73706,2244,28505,66062,26798,82298,56362,33500,9396,68607,34268,78121,24565,46596,56749,56610,46708,29820,7555,
    69820,45843,25652,11022,5038,8621,23674,49852,976,48180,17042,77782,54481,30843,3089,55710,12554,45932,67343,77958,77206,67735,50271,28481,//1940
    3834,66817,46184,32181,25804,30019,44695,71424,22190,69767,38352,12795,75784,51968,24352,76611,33828,66762,2292,12429,12243,2267,71758,49446,
    25338,1408,67714,53206,47360,51034,66230,5945,43610,4118,59551,33373,10306,72443,45018,10690,54367,984,22902,33308,33067,23421,6407,70771,
    46490,22732,2404,74413,68310,72154,670,27089,64401,25369,80337,54737,31130,7470,65910,32099,75308,22301,43829,54495,53923,44486,27170,5344,
    67155,43624,22975,8825,2426,6512,21238,47865,85183,46246,15053,75734,52562,28549,1131,53186,10532,43295,65323,75356,75279,65250,48458,26085,
    2066,64416,44362,29691,23879,27430,42706,68811,20195,67212,36324,10320,73606,49523,21903,74116,31087,64184,85747,9814,9251,86111,68859,47012,
    22579,85475,65033,50910,44678,48757,63512,3728,40889,2033,56922,31457,7848,70620,42695,8779,52045,85234,20447,30879,30429,20775,3611,67997,
    43580,19890,85821,71513,65276,69158,84008,23962,61377,22140,77472,51527,28548,4449,63651,29336,73263,19715,41837,51950,51862,41856,24971,2563,
    64813,40702,20520,5798,86273,3403,18560,44690,82333,43055,12019,72632,49408,25649,84377,50550,7499,40899,62416,73077,72392,62927,45457,23593,
    85268,61712,40969,26823,20356,24481,39116,65835,16594,64238,32809,7363,70295,46599,18896,71291,28449,61548,83462,7377,7186,83762,66804,44571,
    20323,82775,62446,47849,41726,45306,60267,86346,37481,84427,53460,27360,4397,66593,39311,4989,48819,81812,17499,27883,27823,18149,1300,65598,//1950
    41422,17522,83606,68978,62800,66341,81158,20883,58155,18922,73952,48288,24831,1237,59846,26165,69490,16610,38183,48960,48396,39063,21738,1,
    61785,38302,17574,3400,83238,822,15302,41797,78841,39829,8418,69150,45878,22045,81057,46967,4422,37419,59545,69730,69694,59736,42933,20586,
    82922,58878,38753,24065,18146,21630,36756,62721,13938,60767,29764,3593,66894,42726,15275,67509,24763,57952,79825,3974,3657,80523,63419,41485,
    17117,79861,59441,45138,38912,42803,57550,83972,34690,82042,50449,24840,1150,63894,35944,2152,45471,78913,14238,24979,24634,15250,84509,62659,
    38152,14510,80256,65925,59457,63304,77924,17870,55078,15859,71005,45079,21952,84270,57002,22733,66706,13250,35528,45781,45909,36051,19366,83452,
    59417,35296,15115,277,80667,84015,12669,38605,76198,36752,5747,66221,43079,19192,78012,44086,1136,34502,56153,66859,66354,56990,39726,17967,
    79825,56315,35677,21478,15007,18987,33529,60072,10702,58223,26683,1228,64089,40488,12723,65251,22331,55562,77398,1450,1201,77940,60956,38914,
    14660,77307,56951,42506,36292,39947,54741,80818,31750,78660,47531,21411,84805,60626,33430,85553,43129,76129,11948,22278,22313,12546,82175,59980,
    35898,11930,78130,63453,57395,60869,75782,15387,52722,13325,68403,42584,19192,81925,54244,20609,64074,11304,32988,43858,43323,34013,16636,81258,
    56547,33002,12189,84377,77766,81758,9813,36351,73353,34408,2914,63735,40359,16645,75584,41662,85522,32330,54519,64909,64921,55100,38264,15953,//1960
    78156,54066,33746,18987,12879,16324,31327,57302,8476,55334,24360,84604,61595,37414,10099,62310,19752,52945,75056,85641,85571,76060,59154,37166,
    12896,75473,55040,40474,34169,37771,52454,78640,29368,76590,45075,19445,82265,58676,30820,83547,40520,74111,9473,20399,20094,10910,80199,58514,
    33986,10431,76064,61714,55029,58779,73119,12967,49917,10687,65666,39840,16657,79151,51924,17849,61910,8607,30974,41328,41539,31760,15156,79312,
    55340,31263,11095,82637,76559,79790,8300,34028,71461,31785,703,61007,37927,13963,72969,39061,82766,29798,51690,62440,62106,52733,35583,13771,
    75717,52131,31566,17268,10838,14684,29203,55563,6092,53413,21726,82540,58882,35289,7476,60160,17270,50757,72667,83395,83192,73748,56732,34823,
    10460,73179,52668,38267,31881,35574,50189,76290,27026,73921,42577,16401,79619,55390,28136,80262,37921,70988,7003,17445,17715,8045,77865,55688,
    31699,7650,73849,59018,52913,56206,71081,10507,47846,8272,63378,37369,13999,76549,48891,15144,58662,5881,27671,38624,38243,29066,11848,76577,
    51970,28446,7643,79753,73065,76921,4853,31267,68147,29150,83945,58396,34897,11243,70031,36171,79884,26770,48863,59374,59357,49711,32895,10785,
    73008,49090,28732,14068,7834,11284,26091,52011,2987,49782,18689,78901,55891,31688,4446,56600,14125,47213,69400,79862,79880,70264,53478,31421,
    7299,69827,49542,34906,28707,32179,46904,72896,23627,70639,39133,13358,76231,52612,24846,77633,34673,68339,3692,14654,14263,5072,74239,52540,//1970
    27906,4359,69925,55615,48884,52686,66960,6853,43688,4499,59331,33574,10267,72883,45612,11714,55812,2692,25114,35588,35797,26036,9342,73433,
    49310,25139,4813,76283,70084,73285,1730,27449,64870,25169,80519,54370,31373,7350,66509,32581,76506,23565,45705,56487,56363,46961,29922,7973,
    69919,46092,25452,10869,4356,7946,22433,48621,85583,46429,14810,75634,52041,28532,768,53607,10764,44466,66435,77409,77258,68040,51023,29261,
    4795,67540,46805,32321,25626,29198,43500,69531,20032,66962,35499,9456,72666,48610,21430,73720,31504,64706,879,11436,11878,2307,72277,50156,
    26250,2174,68352,53381,47147,50199,64890,4032,41231,1420,56521,30385,7164,69704,42293,8617,52397,86112,21724,32761,32556,23442,6369,71133,
    46642,23106,2368,74395,67686,71376,85587,25376,62064,22864,77473,51851,28250,4706,63501,29895,73692,20891,43083,53881,53914,44488,27656,5706,
    67863,44065,23605,9025,2649,6135,20744,46632,83760,44060,12721,72824,49672,25418,84614,50414,8141,41353,63836,74439,74749,65219,48649,26588,
    2592,65039,44817,30057,23891,27214,41960,67772,18512,65306,33785,7773,70617,46814,19060,71806,28944,62724,84654,9429,9241,276,69601,48057,
    23493,86396,65538,51193,44378,48115,62277,2121,38830,86030,54311,28569,5077,67712,40253,6403,50385,83782,19802,30470,30767,21246,4668,68985,
    44933,20917,568,72098,65789,68980,83682,22961,60268,20522,75824,49620,26636,2519,61710,27638,71607,18520,40754,51450,51493,42083,25275,3364,//1980
    65558,41758,21323,6698,307,3769,18302,44311,81287,41965,10359,71080,47512,23983,82629,49090,6193,39911,61772,72769,72509,63356,46275,24631,
    155,63053,42328,27991,21274,24950,39161,65247,15599,62573,30953,4979,68075,44123,16905,69313,27103,60371,82929,7067,7446,84198,67685,45489,
    21522,83816,63582,48634,42432,45524,60263,85809,36651,83186,51942,25721,2593,65047,37777,4049,48003,81697,17464,28457,28332,19100,2020,66595,
    42051,18302,83924,69373,62679,66259,80540,20286,57057,17856,72517,46934,23346,86292,58673,25210,68990,16373,38555,49539,49532,40238,23283,1368,
    63305,39453,18707,4041,83781,823,15215,41146,78152,38575,7196,67447,44315,20186,79456,45341,3181,36447,59073,69712,70169,60646,44181,22060,
    84482,60372,40062,25051,18728,21761,36367,61928,12636,59275,27863,1797,64845,41063,13536,66347,23677,57532,79605,4451,4369,81860,64856,43327,
    18780,81623,60700,46197,39217,42718,56648,82652,32735,79801,47938,22245,85119,61562,34153,590,44647,78316,14380,25252,25540,16163,85932,63952,
    39810,15857,81769,66907,60392,63515,77944,17087,54103,14200,69293,42991,19974,82265,55215,21240,65491,12530,35070,45846,46135,36719,20068,84473,
    60355,36419,16029,1230,81248,84495,12594,38336,75235,35612,3913,64380,40765,17128,75832,42373,86033,33577,55639,66908,66812,57877,40857,19320,
    81194,57693,36840,22441,15558,19155,33176,59192,9326,56243,24378,84766,61228,37290,9932,62449,20248,53729,76429,836,1410,78415,62050,40019,//1990
    16087,78425,58104,43100,36735,39716,54282,79703,30413,76814,45497,19127,82379,58268,31035,83571,41241,74886,10867,21910,22070,12945,82560,60818,
    36511,12749,78497,63810,57128,60484,74708,14213,50920,11528,66139,40448,16815,79729,52044,18606,62300,9766,31889,43027,43022,33951,17052,81793,
    57391,33769,13029,84910,78152,81639,9431,35341,72103,32503,913,61184,37922,13849,73078,39018,83267,30150,52802,63428,63933,54411,38029,15948,
    78487,54444,34256,19298,13062,16081,30708,56160,6845,53308,21892,82052,58762,34860,7462,60225,17707,51553,73745,84961,84936,75958,58973,37363,
    12845,75627,54771,40244,33364,36867,50886,76889,27003,74051,42148,16462,79260,55780,28304,81290,38914,72780,8832,19891,20135,10883,80535,58607,
    34287,10350,76074,61243,54579,57784,72121,11393,48362,8586,63647,37424,14400,76722,49729,15770,60145,7206,29922,40722,41193,31764,15240,79553,
    55468,31351,10917,82289,75847,78880,6976,32569,69566,29873,84751,58796,35363,11726,70578,37151,80929,28547,50710,62085,62078,53253,36292,14822,
    76689,53164,32212,17693,10635,14072,27897,53803,3790,50726,18802,79354,55825,32122,4790,57536,15355,49031,71745,82715,83303,74052,57695,35787,
    11829,74241,53823,38810,32262,35150,49477,74760,25260,71545,40147,13747,77099,53046,26046,78665,36599,70291,6501,17534,17871,8690,78447,56628,
    32442,8583,74424,59598,52960,56115,70318,9570,46210,6564,61114,35263,11636,74561,46979,13711,57550,5255,27493,38848,38884,29960,13022,77846,//2000
    53356,29778,8929,80836,73948,77444,5062,30953,67490,27852,82415,56263,32802,8774,67941,34028,78371,25468,48301,59136,59812,50428,34133,12090,
    74610,50521,30245,15198,8853,11767,26297,51628,2238,48546,17086,77064,53771,29691,2358,55018,12662,46523,68958,80269,80509,71624,54854,33262,
    8863,71555,50720,36013,29092,32386,46349,72168,22229,69145,37183,11428,74139,50648,23058,76090,33614,67609,3633,14907,15191,6201,75909,54228,
    29913,6142,71773,56999,50138,53318,67399,6625,43348,3552,58426,32211,9076,71409,44376,10395,54775,1790,24558,35329,35913,26500,10137,74496,
    50579,26494,6182,77517,71110,74006,2057,27435,64370,24444,79312,53167,29794,6042,65001,31527,75400,22991,45198,56540,56546,47698,30761,9296,
    71217,47718,26836,12334,5320,8734,22531,48363,84639,45093,13019,73551,49887,26262,85247,51754,9541,43402,66083,77188,77691,68505,52009,30125,
    6010,68449,47892,32936,26279,29245,43479,68825,19223,65516,34024,7586,70904,46810,19874,72477,30568,64273,689,11723,12241,2993,72844,50868,
    26690,2611,68424,53373,46728,49697,63951,3068,39805,53,54703,28761,5209,68087,40570,7334,51248,85469,21397,32918,33033,24259,7337,72225,
    47647,24020,2987,74766,67651,71018,84826,24265,60649,21070,75543,49530,26009,2142,61269,27513,71856,19115,42003,53008,53775,44553,28334,6407,
    68926,44861,24471,9337,2781,5532,19829,44988,81841,41633,10163,70104,46943,22872,82147,48417,6280,40142,62789,74104,74549,65673,49102,27507,//2010
    3277,65912,45176,30319,23398,26444,40318,65846,15792,62470,30440,4589,67320,43908,16406,69638,27253,61477,83945,9018,9295,468,70139,48601,
    24234,589,66143,51455,44462,47665,61536,724,37180,83731,51953,25728,2443,64851,37832,4010,48540,82139,18702,29613,30356,21007,4735,69095,
    45217,21102,805,72095,65691,68515,82947,21798,58689,18570,73399,47036,23676,86158,58821,25301,69376,17048,39509,50988,51232,42486,25711,4259,
    66250,42674,21795,7169,135,3426,17199,42932,79165,39542,7382,67873,44085,20481,79348,45958,3685,37744,60449,71823,72400,63491,47045,25381,
    1232,63794,43107,28187,21339,24307,38347,63710,13955,60285,28689,2273,65534,41425,14483,67035,25173,58831,81767,6401,7116,84315,67999,46075,
    22101,84424,63960,48821,42210,45008,59249,84563,34910,81386,49708,23649,198,63010,35578,2306,46262,80465,16400,27930,28058,19340,2465,67447,
    42942,19413,84841,70276,63160,66515,80236,19618,55859,16253,70593,44646,21038,83718,56398,22809,67114,14504,37325,48396,49065,39874,23555,1673,
    64121,40138,19705,4677,84486,924,15163,40349,77118,36873,5344,65232,42107,18016,77434,43710,1777,35641,58477,69738,70299,61284,44748,22958,
    85132,61167,40454,25431,18579,21500,35481,60910,10960,57541,25578,86049,62425,39016,11577,64913,22606,57002,79532,4777,5055,82728,65901,44358,
    19799,82473,61392,46613,39404,42569,56282,81921,31876,78549,46698,20613,83660,59804,32763,85488,43674,77432,14107,25165,26026,16778,561,64932,//2020
    40997,16782,82719,67429,60812,63439,77698,16394,53221,13018,67917,41520,18319,80776,53628,20088,64366,12055,34733,46260,46717,38014,21415,86349,
    62034,38336,17436,2570,81814,84795,12003,37447,73546,33745,1537,62020,38269,14809,73737,40559,84727,32611,55336,66931,67518,58818,42364,20881,
    83079,59360,38541,23645,16562,19454,33172,58406,8314,54539,22690,82657,59429,35415,8561,61266,19591,53386,76523,1239,2123,79349,63164,41229,
    17349,79628,59213,43978,37351,39972,54123,79173,29391,75557,43780,17446,80389,56651,29341,82488,40266,74607,10783,22472,22789,14176,83807,62420,
    37951,14392,79813,65178,58022,61274,74901,14145,50217,10463,64576,38520,14683,77351,49879,16415,60701,8344,31257,42639,43428,34518,18260,82968,
    58973,35079,14511,85899,79123,81942,9583,34731,71307,30988,85684,59052,35800,11568,70946,37111,81659,29096,52139,63459,64306,55383,39134,17395,
    79779,55772,35160,19990,13154,15864,29832,55040,5093,51475,19529,79830,56204,32660,5187,58439,16088,50483,73006,84753,85095,76554,59841,38510,
    14059,76897,55853,41142,33867,37009,50565,76150,25911,72568,40539,14499,77397,53618,26450,79235,37309,71099,7690,18783,19614,10442,80659,58759,
    34894,10832,76825,61654,55035,57697,71882,10520,47244,6930,61776,35275,12121,74503,47482,13874,58292,5889,28665,40065,40583,31741,15205,80025,
    55811,32041,11284,82774,75775,78703,6037,31393,67554,27642,81846,55854,32105,8669,67616,34560,78746,26790,49492,61210,61700,53052,36433,14953,//2030
    76964,53253,32275,17430,10238,13234,26879,52249,2087,48449,16517,76603,53306,29403,2551,55374,13785,47694,70953,82141,83115,73931,57747,35707,
    11740,73853,53312,37909,31188,33689,47830,72823,23125,69273,37652,11299,74427,50658,23536,76673,34647,69027,5398,17147,17629,9044,78772,57329,
    32859,9140,74468,59602,52314,55337,68861,7960,43998,4230,58378,32440,8669,71541,44117,10882,55193,3072,26008,37628,38436,29742,13467,78332,
    54242,30409,9641,80983,73914,76621,3945,28994,65320,24984,79572,53022,29829,5751,65317,31636,76409,23944,47196,58557,59589,50668,34579,12810,
    75313,51226,30664,15339,8468,10932,24801,49708,86065,45776,13819,73958,50439,26891,86029,53019,10918,45506,68230,80139,80600,72161,55500,34221,
    9779,72631,51565,36826,29478,32539,45944,71398,20931,67461,35188,9102,71820,48128,20904,73912,32067,66166,2906,14297,15247,6285,76529,54740,
    30811,6791,72664,57502,50738,53383,67409,5986,42535,2094,56777,30112,6875,69122,42148,8488,53100,751,23836,35358,36210,27470,11203,76031,
    51973,28097,7392,78693,71695,74404,1733,26878,63037,22928,77103,50929,27116,3559,62444,29373,73542,21700,44459,56405,57016,48644,32148,10904,
    72964,49384,28339,13509,6147,9086,22511,47831,83853,43817,11693,71810,48333,24453,83849,50284,8606,42540,65800,77067,78137,69095,53068,31199,
    7380,69626,49157,33792,27037,29465,43494,68337,18524,64506,32844,6346,69516,45611,18565,71561,29608,63857,294,11947,12520,3893,73765,52333,//2040
    28049,4360,69870,54998,47832,50771,64318,3258,39232,85692,53347,27312,3470,66362,38882,5737,49974,84354,20779,32478,33147,24519,8108,73060,
    48869,25163,4331,75829,68708,71559,85200,23947,60131,19836,74253,47710,24396,339,59888,26246,71088,18652,41994,53332,54418,45402,29313,7403,
    69880,45655,25085,9660,2825,5227,19175,44026,80484,40108,8248,68262,44829,21166,80404,47346,5369,39976,62822,74769,75308,66863,50200,28833,
    4309,67004,45816,30907,23454,26392,39744,65162,14687,61271,28998,3026,65713,42158,14874,68038,26149,60429,83556,8735,9677,875,71070,49373,
    25309,1290,66935,51700,44660,47216,60995,85930,35928,81917,50178,23591,441,62765,35936,2307,47084,81133,17996,29508,30547,21787,5691,70463,
    46516,22509,1822,72894,65824,68230,81855,20293,56398,16067,70291,44035,20373,83277,55956,23027,67355,15659,38502,50569,51206,42932,26433,5265,
    67298,43753,22637,7780,273,3116,16317,41508,77267,37151,4808,64965,41384,17684,77108,43808,2246,36441,59817,71270,72396,63452,47417,25589,
    1718,63981,43432,28065,21203,23585,37472,62201,12224,58038,26252,85990,62762,38771,11886,64904,23240,57593,80759,6118,6965,84764,68403,46890,
    22677,85227,64356,49292,42130,44872,58417,83563,33112,79383,46978,20792,83283,59732,32229,85595,43486,78112,14655,26666,27458,19111,2752,67883,
    43626,19981,85380,70458,63116,65929,79347,18085,54072,13803,68043,41534,18066,80437,53503,19914,64793,12465,35963,47463,48774,39932,24060,2275,//2050
    64884,40680,20120,4601,84077,86305,13734,38393,74780,34239,2396,62273,38921,15132,74464,41303,85833,33997,56981,68960,69682,61325,44872,23601,
    85666,62006,40931,25971,18527,21320,34593,59830,9241,55693,23321,83727,59953,36485,9149,62443,20483,54895,77943,3264,4146,81913,65683,44186,
    20121,82708,61936,46868,39751,42397,56023,80970,30768,76727,44812,18202,81382,57326,30554,83369,41871,75933,12918,24389,25522,16681,666,65351,
    41491,17414,83229,67847,60885,63222,76938,15259,51425,10933,65203,38785,15181,77992,50772,17861,62328,10724,33686,45844,46531,38286,21758,551,
    62508,38895,17702,2793,81640,84472,11247,36467,72185,32127,86108,59948,36267,12677,72016,38868,83687,31680,55096,66753,67919,59124,43062,21291,
    83694,59530,38783,23351,16282,18618,32353,57080,7032,52871,21094,80849,57694,33689,6918,59898,18392,52725,76100,1476,2554,80369,64209,42653,
    18557,80965,60104,44799,37574,40031,53510,78406,27952,74069,41732,15500,78100,54597,27190,80656,38599,73352,9923,22095,22922,14756,84833,63727,
    39467,15916,81224,66292,58747,61456,74593,13207,48914,8598,62638,36199,12646,75183,48269,14879,59835,7660,31228,42819,44182,35402,19580,84253,
    60505,36347,15791,268,79678,81812,9100,33571,69792,29029,83490,56792,33483,9608,69117,35965,80748,28967,52191,64202,65094,56712,40370,19033,
    81185,57442,36444,21389,13999,16666,29938,54996,4323,50564,18048,78293,54390,30900,3503,56928,14991,49646,72765,84759,85686,77272,61008,39641,//2060
    15460,78112,57177,42145,34853,37531,50977,75946,25543,71491,39352,12689,75679,51575,24724,77542,36107,70238,7401,18988,20346,11606,82177,60486,
    36717,12565,78376,62850,55838,58004,71680,9833,46000,5342,59640,33039,9460,72086,44890,11853,56379,4750,27828,40057,40906,32782,16422,81715,
    57387,33793,12624,84035,76417,79108,5769,30854,66453,26333,80209,54070,30282,6755,65960,32884,77567,25649,48969,60754,61880,53257,37199,15621,
    78030,54037,33244,17915,10717,13074,26616,51307,1066,46860,14962,74695,51532,27518,814,53756,12336,46580,70033,81692,82853,74161,58111,36482,
    12526,74887,54173,38811,31702,34048,47590,72309,21879,67798,35485,9105,71765,48220,20912,74437,32472,67312,3910,16136,16910,8750,78727,57602,
    33242,9681,74915,59998,52401,55145,68219,6872,42475,2203,56107,29740,6068,68733,41771,8565,53554,1577,25206,36939,38309,29571,13663,78287,
    54378,30129,9394,80196,73066,75173,2391,26872,63086,22331,76834,50116,26904,2993,62660,29490,74493,22735,46212,58263,59381,50992,34792,13342,
    75521,51554,30496,15160,7690,10096,23338,48219,83990,43756,11328,71582,47767,24356,83423,50592,8705,43562,66739,78973,79959,71775,55525,34316,
    10053,72743,51604,36496,28908,31459,44594,69479,18837,64816,32555,6033,69013,45097,18315,71312,29993,64269,1575,13285,14803,6173,76895,55279,
    31606,7455,73263,57629,50500,52450,65942,3825,39842,85352,53235,26511,3079,65697,38751,5785,50583,85446,22356,34658,35688,27611,11400,76715,//2070
    52510,28900,7805,79136,71511,74036,591,25448,60868,20534,74232,48005,24122,690,59904,27068,71832,20220,43633,55705,56877,48477,32402,10987,
    73332,49465,28575,13343,6012,8420,21777,46456,82378,41695,9552,69183,45866,21804,81516,48105,6863,41226,64952,76747,78186,69582,53743,32117,
    8286,70574,49920,34441,27358,29556,43112,67649,17223,62924,30595,3976,66607,42869,15569,69030,27154,62073,85233,11238,12202,4243,74380,53398,
    29120,5605,70832,55879,48213,50888,63864,2459,37945,84055,51416,25063,1215,63900,36750,3590,48452,82983,20190,32105,33539,25030,9221,74071,
    50228,26147,5392,76276,69038,71150,84617,22660,58738,17932,72358,45583,22365,84765,58059,24750,69793,17886,41443,53393,54653,46227,30224,8781,
    71180,47217,26349,10962,3611,5888,19177,43875,79659,39246,6830,66964,43181,19737,78830,46019,4098,38972,62050,74297,75166,67020,50687,29560,
    5266,68080,46944,31970,24367,27022,40081,65022,14241,60258,27831,1365,64209,40388,13547,66665,25347,59708,83405,8717,10174,1478,72105,50406,
    26644,2441,68199,52564,45432,47409,60923,85212,34855,80321,48243,21435,84485,60614,33807,792,45776,80629,17718,29989,31121,22931,6723,71836,
    47567,23713,2550,73662,66017,68399,81402,19792,55297,14950,68714,42517,18661,81710,54519,21819,66576,15148,38564,50836,51985,43738,27560,6199,
    68334,44417,23236,7903,268,2607,15722,40420,76199,35625,3426,63205,39897,15970,75746,42438,1305,35745,59619,71481,73078,64511,48791,27128,//2080
    3321,65463,44715,28984,21723,23614,36994,61252,10757,56278,24030,83743,60170,36449,9382,62904,21237,56229,79553,5632,6726,85232,69067,48111,
    23876,308,65492,50382,42569,44999,57748,82484,31337,77287,44491,18158,80666,57142,30039,83567,42115,76938,14211,26365,27816,19488,3654,68640,
    44730,20740,86263,70774,63335,65392,78578,16488,52257,11290,65479,38594,15310,77706,51131,17915,63231,11459,35329,47382,48903,40498,24669,3163,
    65661,41577,20758,5207,84265,86331,13189,37622,73338,32626,125,59996,36170,12596,71743,38989,83623,32309,55596,68118,69174,61263,45032,24038,
    86140,62579,41354,26335,18592,21175,34061,58931,7945,53900,21237,81132,57342,33529,6529,59748,18411,52973,76790,2373,4019,81996,66387,44887,
    21182,83459,62748,47085,39796,41682,55020,79196,28698,74042,41882,14939,77967,53943,27169,80417,39109,73897,11187,23493,24905,16817,916,66123,
    42118,18278,83674,68283,60682,62864,75834,13992,49446,8905,62633,36323,12442,75459,48222,15545,60225,8863,32215,44618,45756,37714,21584,474,
    62679,39003,17851,2686,81385,83789,10331,35018,70567,29975,83964,57367,33921,10056,69780,36536,81802,29863,53744,65589,67205,58628,42966,21338,
    84037,59858,39242,23595,16443,18363,31789,55977,5474,50844,18594,78144,54630,30786,3844,57313,15804,50784,74242,288,1451,79881,63740,42690,
    18485,81244,60100,44959,37254,39683,52537,77268,26167,72092,39261,12922,75359,51896,24731,78397,36914,71929,9188,21527,22925,14717,85154,63782,//2090
    39681,15693,81013,65544,57944,60082,73173,11222,46949,6129,60293,33506,10217,72660,46132,12945,58370,6621,30649,42719,44406,35987,20274,85082,
    61211,36957,16093,325,79322,81185,8038,32329,68141,27358,81429,54869,31220,7631,66925,34186,78937,27678,51064,63673,64817,56999,40828,19885,
    81987,58391,37080,21935,14029,16442,29139,53880,2744,48693,15961,75994,52202,28611,1627,55074,13747,48505,72325,84467,86112,77824,62203,40815,
    17064,79409,58588,42926,35451,37264,50366,74421,23709,68946,36683,9709,72806,48831,22263,75584,34529,69362,6884,19180,20768,12622,83251,61968,
    38067,14113,79589,64050,56486,58467,71419,9325,44720,3920,57590,31101,7226,70224,43084,10549,55373,4236,27714,40334,41525,33629,17462,82818,
    58522,34859,13578,84806,76957,79343,5711,30369,65706,25080,78832,52216,28563,4737,64371,31261,76587,24852,48889,60945,62721,54296,38717,17141,
    79820,55601,34886,19146,11866,13673,26981,51049,459,45689,13390,72771,49250,25228,84741,51696,10339,45319,69021,81556,82999,75131,59233,38213,
    14153,76824,55707,40371,32608,34795,47564,72074,20900,66664,33771,7346,69708,46225,18960,72665,31089,66219,3443,15981,17408,9454,79941,58816,
    34723,10906,76137,60726,52925,55030,67853,5845,41311,466,54433,27665,4269,66743,40180,6994,52416,633,24698,36742,38525,30124,14563,79427,
    55724,31520,10785,81403,74041,75787,2596,26680,62424,21405,75455,48699,25110,1404,60813,28026,72886,21596,45041,57609,58774,50921,34775,13820,//2100
    75979,52395,31162,16026,8179,10564,23249,47910,83076,42531,9653,69657,45733,22215,81553,48765,7411,42364,66160,78453,80022,71815,56059,34705,
    10796,73174,52212,36613,29028,30929,43936,68068,17257,62522,30166,3178,66238,42242,15739,69063,28169,63028,760,13069,14840,6639,77365,55936,
    32043,7875,73317,57551,49969,51757,64748,2513,38004,83501,50886,24316,542,63497,36447,3943,48861,84239,21419,34200,35477,27728,11589,77012,
    52651,28946,7506,78614,70558,72818,85390,23593,58792,18219,71894,45425,21727,84482,57690,24762,70096,18542,42635,54872,56730,48476,32964,11514,
    74191,50012,29190,13383,5897,7556,20625,44528,80164,38879,6546,65895,42497,18501,78234,45222,4101,39096,63019,75556,77205,69336,53632,32594,
    8700,71306,50292,34811,27062,29018,41719,65953,14684,60210,27261,730,63122,39710,12552,66463,25007,60381,84079,10427,11865,4079,74537,53553,
    29410,5714,70874,55552,47634,49774,62408,375,35589,81093,48406,21623,84460,60603,34033,1010,46574,81395,19261,31473,33423,25108,9635,74507,
    50827,26587,5842,76409,69030,70708,83890,21459,57161,15962,69975,43011,19431,81956,55059,22216,67273,16056,39769,52472,53896,46150,30186,9248,
    71491,47829,26609,11343,3483,5738,18411,42965,78103,37476,4523,64476,40430,16912,76122,43410,1982,37116,60930,73491,75139,67223,51532,30414,
    6488,68999,47915,32354,24572,26468,39267,63410,12430,57733,25261,84701,61291,37286,10761,64039,23176,57989,82226,8132,10085,1929,72875,51501,//2110
    27804,3642,69200,53349,45791,47410,60374,84336,33429,78752,46204,19514,82243,58720,31760,85604,44164,79503,16684,29453,30737,23026,6934,72440,
    48160,24545,3180,74337,66297,68541,81041,19181,54246,13632,67173,40750,16958,79842,52991,20227,65511,14094,38116,50427,52184,43965,28346,6939,
    69529,45424,24540,8827,1283,3018,16005,39930,75459,34135,1720,61018,37632,13612,73466,40452,85917,34507,58614,71097,72865,64862,49196,27963,
    4067,66461,45457,29792,22093,23907,36696,60818,9643,55061,22182,81960,58005,34576,7485,61480,20101,55630,79397,5913,7373,86101,70089,49121,
    24811,1046,65984,50565,42427,44506,56963,81346,30039,75637,42861,16205,78961,55234,28624,82145,41342,76319,14278,26641,28695,20494,5074,69977,
    46245,21925,1018,71414,63810,65285,78265,15663,51264,9962,64011,37004,13564,76062,49349,16486,61744,10535,34463,47202,48842,41134,25362,4419,
    66786,43025,21823,6340,84786,335,12849,37094,72087,31246,84623,58131,34105,10702,69973,37460,82479,31430,55267,68041,69696,61987,46288,25355,
    1385,64027,42829,27309,19311,21147,33632,57650,6323,51510,18757,78163,54633,30707,4247,57679,16993,51957,76391,2392,4509,82790,67459,46082,
    22475,84685,63898,47978,40419,41896,54789,78516,27490,72512,39863,12891,75605,51915,25069,78912,37693,73158,10589,23513,24999,17393,1420,66952,
    42720,19069,84111,68795,60734,62880,75314,13328,48253,7493,60826,34287,10269,73126,46113,13457,58701,7523,31616,44231,46096,38160,22601,1394,//2120
    63949,39949,18943,3268,81954,83699,10107,34027,69384,28022,81846,54654,31139,6998,66801,33683,79217,27777,52083,64623,66675,58769,43392,22224,
    84948,60918,40028,24236,16564,18182,30964,54873,3707,48932,16080,75692,51751,28186,1082,54991,13588,49110,72881,85883,1003,79894,63987,43208,
    19000,81785,60365,45012,36823,38884,51208,75544,24069,69658,36731,10139,72769,49143,22422,76028,35121,70151,8022,20428,22437,14310,85298,63924,
    40240,16073,81615,65742,58147,59685,72612,9990,45506,4126,58124,31033,7635,70070,43483,10562,55967,4678,28720,41343,43057,35211,19505,84837,
    60898,37047,15979,436,79036,80930,7178,31345,66420,25477,78887,52318,28307,4919,64221,31822,76874,25983,49817,62720,64300,56652,40801,19870,
    82109,58342,36972,21481,13364,15291,27705,51866,486,45832,13015,72564,48971,25167,85100,52254,11637,46722,71265,83754,85960,77855,62535,41079,
    17390,79447,58526,42440,34767,36122,48982,72653,21698,66710,34222,7248,70158,46448,19794,73623,32597,68089,5718,18692,20354,12774,83314,62394,
    38176,14365,79324,63764,55570,57464,69788,7631,42520,1726,55101,28673,4734,67793,40837,8399,53658,2696,26793,39624,41493,33761,18182,83535,
    59607,35684,14498,85196,77202,78844,4931,28753,63846,22462,76160,49051,25576,1597,61573,28620,74369,23033,47539,60120,62350,54452,39233,18048,
    80891,56799,35962,20029,12320,13697,26365,49965,85080,43612,10724,70149,46298,22704,82210,49840,8695,44399,68377,81526,83162,75736,59871,39124,//2130
    14919,77698,56255,40857,32599,34566,46745,70939,19243,64690,31523,4869,67318,43766,16980,70802,29960,65296,3302,16004,18119,10206,81213,59957,
    36202,12083,77499,61638,53892,55417,68178,5501,40830,85729,53145,25895,2390,64689,38128,5145,50723,85876,23808,36540,38579,30828,15387,80725,
    56943,32984,11968,82631,74825,76489,2718,26658,61715,20553,73924,47152,23077,85946,58790,26356,71390,20593,44483,57595,59297,51911,36185,15484,
    77780,54145,32722,17248,8974,10843,23041,47138,81935,40861,7843,67412,43633,19854,79633,46808,6097,41218,65748,78317,80597,72629,57439,36147,
    12584,74776,53914,37874,30160,31451,44186,67710,16621,61461,28910,1785,64723,40875,14295,67988,27041,62407,109,12979,14732,7091,77767,56837//2135
};
#pragma -

@end
