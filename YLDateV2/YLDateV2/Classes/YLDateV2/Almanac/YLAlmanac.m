//
//  YLAlmanac.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/3.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLAlmanac.h"
#import "YLLunar.h"
#import "solarlunar.h"
#import "YLLunarData.h"

@implementation YLAlmanac

@synthesize term = _term, zhiShen = _zhiShen, jianChu = _jianChu;
@synthesize star = _star, fetus = _fetus, pengZuBaiJi = _pengZuBaiJi;
@synthesize the5Element = _the5Element, chong = _chong, sha = _sha;
@synthesize monthFeixing = _monthFeixing, dayFeixing = _dayFeixing;
@synthesize feixingGridYear = _feixingGridYear, feixingGridMonth = _feixingGridMonth;
@synthesize feixingGridDay = _feixingGridDay;

+ (instancetype)dateWithDate:(NSDate *)date {
    YLAlmanac *almanac = YLAlmanac.new;
    almanac->_date = date;
    almanac->_explains = NSMutableDictionary.new;
    almanac->_dataProvider = NSMutableDictionary.new;
    if ([YLLunar isLunarValid:date]) {
        [almanac _calculation];
    }
    return almanac;
}

+ (NSArray<NSString *> *)the24Terms {
    return @[@"小寒", @"大寒", @"立春", @"雨水", @"惊蛰", @"春分",
             @"清明", @"谷雨", @"立夏", @"小满", @"芒种", @"夏至",
             @"小暑", @"大暑", @"立秋", @"处暑", @"白露", @"秋分",
             @"寒露", @"霜降", @"立冬", @"小雪", @"大雪", @"冬至"];
}

+ (NSArray<NSString *> *)stems {
    return @[@"甲", @"乙", @"丙", @"丁", @"戊", @"己", @"庚", @"辛", @"壬", @"癸"];
}

+ (NSArray<NSString *> *)branches {
    return @[@"子", @"丑", @"寅", @"卯", @"辰", @"巳", @"午", @"未", @"申", @"酉", @"戌", @"亥"];
}

+ (NSArray<NSString *> *)zhiShens {
    return @[@"青龙", @"明堂", @"天刑", @"朱雀", @"金匮", @"天德",
             @"白虎", @"玉堂", @"天牢", @"玄武", @"司命", @"勾陈"];
}

+ (NSArray<NSString *> *)jianChus {
    return @[@"建", @"除", @"满", @"平", @"定", @"执", @"破", @"危", @"成", @"收", @"开", @"闭"];
}

+ (NSArray<NSString *> *)the28Stars {
    return @[/* zhěn */                  /* dī  mò */
             @"轸水蚓", @"角木蛟", @"亢金龙", @"氐土貉", @"房日兔", @"心月狐", @"尾火虎",
             /* jī */   /* xiè */
             @"箕水豹", @"斗木獬", @"牛金牛", @"女土蝠", @"虚日鼠", @"危月燕", @"室火猪",
               /* yǔ */                            /* mǎo */           /* zī */
             @"壁水貐", @"奎木狼", @"娄金狗", @"胃土雉", @"昴日鸡", @"毕月乌", @"觜火猴",
                         /* àn */          /* zhāng */
             @"参水猿", @"井木犴", @"鬼金羊", @"柳土獐", @"星日马", @"张月鹿", @"翼火蛇"];
}

+ (NSArray<NSString *> *)fetuses {
    static NSArray<NSString *> *fetuses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 胎神按照 60 甲子的顺序排列
        // 共 62 胎神，多出的两个，为特殊的
        fetuses = @[
                    @"占门碓外东南", @"碓磨厕外东南", @"厨灶炉外正南", @"仓库门外正南", @"房床栖外正南", @"占门床外正南", @"占碓磨外正南", @"厨灶厕外西南", @"仓库炉外西南", @"房床门外西南",
                    @"门鸡栖外西南", @"碓磨床外西南", @"厨灶碓外西南", @"仓库厕外西南", @"房床厕外正南", @"占门厕外正南", @"碓磨栖外正西", @"厨灶床外正西", @"仓库碓外西北", @"房床厕外西北",
                    @"占门炉外西北", @"碓磨门外西北", @"厨灶栖外西北", @"仓库床外西北", @"房床碓外正北", @"占门厕外正北", @"碓磨炉外正北", @"厨灶门外正北", @"仓库栖外正北", @"占房床房内北",
                    @"占门碓房内北", @"碓磨厕房内北", @"厨灶炉房内北", @"仓库门房内北", @"房床栖房内南", @"占门床房内南", @"占碓磨房内南", @"厨灶厕房内南", @"仓库炉房内南", @"房床门房内南",
                    @"门鸡栖房内东", @"碓磨床房内东", @"厨灶碓房内东", @"仓库厕房内东", @"房床炉房内东", @"占大门外东北", @"碓磨栖外东北", @"厨灶床外东北", @"仓库碓外东北", @"房床厕外东北",
                    @"占门炉外东北", @"碓磨门外正东", @"厨灶栖外正东", @"仓库床外正东", @"房床碓外正东", @"占门厕外正东", @"碓磨炉外东南", @"厨灶门外东南", @"仓库栖外东南", @"占房床外东南",
                    // code = 7 dayGz = 壬辰 = 28      // code = 2, dayGz = 丙辰 = 52
                    @"仓库床外正北",                     @"厨灶床外正东"
                    ];
        // 其中 code = (月地支.idx + 10) % 12 + 1;
        // 反推回来，月地支.idx = (code + 1) % 12
        // 所以以上两个特殊的胎神，分别对应:
        // 1. 日干支.idx = 28 && 月地支.idx = 8
        // 2. 日干支.idx = 52 && 月地支.idx = 3
    });
    return fetuses;
}

+ (NSArray<NSString *> *)the5Elements {
    return @[@"海中金", @"炉中火", @"大林木", @"路旁土", @"剑锋金", @"山头火",
             @"涧下水", @"城头土", @"白蜡金", @"杨柳木", @"泉中水", @"屋上土",
             @"霹雳火", @"松柏木", @"长流水", @"沙中金", @"山下火", @"平地木",
             @"壁上土", @"金箔金", @"覆灯火", @"天河水", @"大驿土", @"钗钏金",
             @"桑拓木", @"大溪水", @"沙中土", @"天上火", @"石榴木", @"大海水"];
}

+ (NSArray<NSString *> *)the9Feixing {
    return @[@"一白-贪狼星(水)", @"二黑-巨门星(土)", @"三碧-禄存星(木)",
             @"四绿-文曲星(木)", @"五黄-廉贞星(土)", @"六白-武曲星(金)",
             @"七赤-破军星(金)", @"八白-左辅星(土)", @"九紫-右弼星(火)"];
}

+ (NSArray<NSString *> *)explainsOfThe9Feixing {
    return @[@"吉星，五行属水。一白星在得令的时候，代表官升、名气、中状元、官运和财运。失令的时候，此星为桃花劫，破财损家，甚至性病、绝症，异乡流亡。",
             @"凶星，五行属土。二黑星代表病符。此星在得令的时候并非病符，代表位列尊崇，能成霸业。但此星失令的时候，是一极大凶星，破财损家，代表死亡绝症、破财横祸，与五黄星并列为最凶之星。此星亦代表招来阴灵。",
             @"凶星，五行属木。三碧星代表是非。此星在得令时代表因口材而成名，大利律师、法官急鬼才等职。但此星失令的时候，代表是非官非，破财招刑。",
             @"吉星，五行属木。文曲星在得令的时代表文化艺术、才华、文思敏捷。但失令时为桃花劫星必招酒色之祸。",
             @"凶星，五行属土。廉贞星得令时代表位处中极、威崇无比，如皇帝之最尊最贵。但此星失令的时，称为五黄煞又名正关煞，代表死亡绝症、血光之灾，家破人亡。此星亦必招邪灵之物。",
             @"吉星，五行属金。六白是偏财星，与一白、八白合称三大财星。六白得令时丁财两旺，失令时，为失财星，可令倾家荡产。",
             @"凶星，五行属金。七赤星当运的时候，大利以口才工作的人，包括歌星、演说家、占卜家等，大利通讯传播。但七赤星退运时候，代表口舌是非，刀光剑影，世界大战。又代表火险、及身体上呼吸、肺部的毛病。",
             @"吉星，五行属土。八白星得令时为太白财星，能带来功名富贵。田宅科发，为九星中第一吉星。此星失令的时，为失财失义，瘟疫流行，失财于刹间。",
             @"吉星，五行属火。九紫星当令时为一级喜庆星及爱情星，代表桃花人缘及天乙贵人，大利置业及建筑。但此星失令的时为桃花劫星，损丁破财，亦主火灾、爆炸、心脏病、眼疾、流血等。"];
}

- (YLDateUnit *)term {
    if (_term.idx < 0) { return nil; }
    return _term;
}

- (YLDateUnit *)zhiShen {
    if (!_zhiShen) {
        /**
         子午青龙起在申，卯酉之日又在寅。
         寅申须从子上起，巳亥在午不须论。
         唯有辰戌归辰位，丑未原从戌上寻。
         */
        NSInteger beginIndex = self.month.branch.idx;
        NSInteger qinglongBeginIndex = (((beginIndex % 6) + 4) * 2) % 12;
        NSInteger idx = self.day.branch.idx - qinglongBeginIndex;
        idx = (idx + 12) % 12;
        _zhiShen = [YLDateUnit unitWith:self.class.zhiShens[idx]
                                    idx:idx];
    }
    return _zhiShen;
}

- (YLDateUnit *)jianChu {
    if (!_jianChu) {
        int idx = (_jx + 10) % 12;
        _jianChu = [YLDateUnit unitWith:self.class.jianChus[idx]
                                    idx:idx];
    }
    return _jianChu;
}

- (YLDateUnit *)star {
    if (!_star) {
        // 28 星宿每天轮换一个
        // 基准日期 1900-01-01 甲(0)戌(10)日 星宿: 心月狐 (5)
        NSInteger base = 5;
        solar_calendar referenceDay = solar_creat_date(1900, 1, 1);
        solar_calendar now = solar_creat_date((int)self.components.year, (int)self.components.month, (int)self.components.day);
        NSInteger dayOff = now - referenceDay;
        NSInteger idx = (base + dayOff) % 28;
        if (idx < 0) { idx += 28; } // 小于基准日期时
        _star = [YLDateUnit unitWith:[NSString stringWithFormat:@"%@宿星", self.class.the28Stars[idx]]
                                 idx:idx];
    }
    return _star;
}

- (YLDateUnit *)fetus {
    if (!_fetus) {
        // 天干地址的下标
        NSInteger idx = ylStemBranchIndexOf(self.day.stem.idx, self.day.branch.idx);
        if (idx == 28 && self.month.branch.idx == 8) {
            // 特殊胎神1
            idx = 60;
        } else if (idx == 52 && self.month.branch.idx == 3) {
            // 特殊胎神2
            idx = 61;
        }
        _fetus = [YLDateUnit unitWith:self.class.fetuses[idx]
                                  idx:idx];
    }
    return _fetus;
}

- (NSString *)pengZuBaiJi {
    if (!_pengZuBaiJi) {
        NSArray<NSString *> *stem = @[@"甲不开仓财物耗散", @"乙不栽植千株不长", @"丙不修灶必见灾殃", @"丁不剃头头必生疮", @"戊不受田田主不祥",
                                      @"己不破券二比并亡", @"庚不经络织机虚张", @"辛不合酱主人不尝", @"壬不汲水更难提防", @"癸不词讼理弱敌强"];
        NSArray<NSString *> *branch = @[@"子不问卜自惹祸殃", @"丑不冠带主不还乡", @"寅不祭祀神鬼不尝", @"卯不穿井水泉不香", @"辰不哭泣必主重丧", @"巳不远行财物伏藏",
                                        @"午不苫盖屋主更张", @"未不服药毒气入肠", @"申不安床鬼祟入房", @"酉不宴客醉坐颠狂", @"戌不吃犬作怪上床", @"亥不嫁娶不利新郎"];
        _pengZuBaiJi = [NSString stringWithFormat:@"%@ %@", stem[self.day.stem.idx], branch[self.day.branch.idx]];
    }
    return _pengZuBaiJi;
}

- (YLDateUnit *)the5Element {
    if (!_the5Element) {
        NSInteger idx = ylStemBranchIndexOf(self.day.stem.idx, self.day.branch.idx);
        idx /= 2;
        _the5Element = [YLDateUnit unitWith:self.class.the5Elements[idx]
                                        idx:idx];
    }
    return _the5Element;
}

- (YLDateUnit *)chong {
    if (!_chong) {
        NSInteger idx = [YLAlmanacTime chongIndexOfBranch:self.day.branch.idx];
        _chong = [YLDateUnit unitWith:YLLunar.animals[idx]
                                  idx:idx];
    }
    return _chong;
}

- (YLDateUnit *)sha {
    if (!_sha) {
        NSInteger idx = [YLAlmanacTime shaDirectionOfBranch:self.day.branch.idx];
        NSString *direction = YLAlmanacTime.compassDirections[idx];
        if ([direction hasPrefix:@"正"]) {
            direction = [direction substringFromIndex:1];
        }
        _sha = [YLDateUnit unitWith:direction
                                idx:idx];
    }
    return _sha;
}

- (YLDateUnit *)monthFeixing {
    if (!_monthFeixing) {
        YLLunar *lunar = [YLLunar dateWithDate:self.date];
        NSInteger month = lunar.month.idx - 1;
        NSInteger yearBranch = self.year.branch.idx;
        if (month == 11) { // 腊月
            int year = (int)self.components.year;
            unsigned int *terms = YLTermsTable[year - YLMinYear];
            unsigned int lichun = terms[2]; // 立春这一天距离今年元旦多少天
            solar_calendar yuandan = solar_creat_date(year, 1, 1);
            solar_calendar this = solar_creat_date(year, (int)self.components.month, (int)self.components.day);
            long dayOffset = this - yuandan;
            if (dayOffset >= lichun) {
                yearBranch += 11;
                yearBranch %= 12;
            }
        }
        
        // group 0: 子午卯酉 0 3 6 9
        // group 2: 寅申巳亥 2 5 8 11
        // group 3: 辰戌丑未 1 4 7 10
        NSInteger group = yearBranch % 3;
        NSInteger idx = 0;
        if (group == 0) {
            idx = 8 - month;
        } else if (group == 1) {
            idx = 5 - month;
        } else if (group == 2) {
            idx = 2 - month;
        }
        idx += 17;
        idx %= 9;
        _monthFeixing = [YLDateUnit unitWith:self.class.the9Feixing[idx]
                                         idx:idx];
    }
    return _monthFeixing;
}

- (YLDateUnit *)dayFeixing {
    if (!_dayFeixing) {
        int year = (int)self.components.year;
        long xiaZhi = YLTermsTable[year - YLMinYear][11];  // 今年夏至距离今年元旦的天数
        long dongZhi = YLTermsTable[year - YLMinYear][23]; // 今年冬至距离今年元旦的天数
        
        solar_calendar xiaZhiDay = solar_creat_date(year, 1, 1) + xiaZhi;   // 今年夏至
        solar_calendar dongZhiDay = solar_creat_date(year, 1, 1) + dongZhi; // 今年冬至
        
        solar_calendar jiazi = solar_creat_date(1900, 2, 20); // 1900 年的第一个甲子日
        
        long xiaZhiIdx = (xiaZhiDay - jiazi) % 60; // 今年夏至的干支idx
        long dongZhiIdx = (dongZhiDay - jiazi) % 60; // 今年冬至的干支idx
        
        solar_calendar this = solar_creat_date(year, (int)self.components.month, (int)self.components.day); // 当前日期
        
        solar_calendar nearestJiaZiToXiaZhi = xiaZhiDay - xiaZhiIdx, nearestJiaZiToDongZhi = dongZhiDay - dongZhiIdx;
        // 找到距离最近的甲子日
        if (xiaZhiIdx >= 30) { nearestJiaZiToXiaZhi += 60; }
        if (dongZhiIdx >= 30) { nearestJiaZiToDongZhi += 60; }
        
        long gz = (this - jiazi) % 60; // 当前日期的干支
        gz += 60;
        gz %= 60;
        
        long days2xiaZhiJiaZi = labs(this - nearestJiaZiToXiaZhi);
        long days2dongZhiJiaZi = labs(this - nearestJiaZiToDongZhi);
        
        NSInteger idx = 0;
        if (days2xiaZhiJiaZi < days2dongZhiJiaZi) {
            // 靠近夏至的这一批为降序
            if (days2xiaZhiJiaZi == 0) {
                idx = 8;
            } else if (this < nearestJiaZiToXiaZhi) {
                idx = 8 - (days2xiaZhiJiaZi - 1) % 9;
            } else {
                idx = 8 - days2xiaZhiJiaZi % 9;
            }
        } else {
            // 靠近冬至的这一批为升序
            if (days2dongZhiJiaZi == 0) {
                idx = 0;
            } else if (this < nearestJiaZiToDongZhi) {
                idx = (days2dongZhiJiaZi - 1) % 9;
            } else {
                idx = days2dongZhiJiaZi % 9;
            }
        }
        _dayFeixing = [YLDateUnit unitWith:self.class.the9Feixing[idx]
                                       idx:idx];
    }
    return _dayFeixing;
}

- (NSArray<NSNumber *> *)feixingGridYear {
    return _feixingGridYear;
}

- (NSArray<NSNumber *> *)feixingGridMonth {
    return _feixingGridMonth;
}

- (NSArray<NSNumber *> *)feixingGridDay {
    return _feixingGridDay;
}

#pragma mark - Private
// 推算黄历数据
- (void)_calculation {
    // 天干地支
    // 基准日期 1899-02-04: 猪(11) 己亥年(05 11) 丙寅月(02 02) 癸卯日(09 03)
    int year = (int)self.components.year;
    NSInteger yearOffset = year - 1899;
    solar_calendar this = solar_creat_date(year, (int)self.components.month, (int)self.components.day);
    solar_calendar newYearsDay = solar_creat_date(year, 1, 1);
    NSInteger dayOffset = this - newYearsDay;
    unsigned int *terms = YLTermsTable[year - YLMinYear];
    NSInteger term = 0;
    for (int i = 0; i < 24; i++) {
        if (dayOffset <= terms[i]) {
            term = i - 1;
            if (dayOffset == terms[i]) {// 刚好这一天是节气
                term = i;
                _term = [YLDateUnit unitWith:self.class.the24Terms[i]
                                         idx:i];
                int seconds = YLTermsTimeTable[year - YLMinYear][term];
                NSInteger second = seconds % 60;
                NSInteger minute = seconds / 60;
                NSInteger hour = minute / 60;
                minute %= 60;
                
                _termTime = [YLTermTime termTimeWith:hour
                                              minute:minute
                                              second:second];
            } else {
                _term = [YLDateUnit unitWith:@"这天不是节气"
                                         idx:-1];
            }
            break;
        } else if (i == 23) {
            term = 23;
        }
    }
    // 按节气计算月份(每个月份两个节气)
    NSInteger monthOffset = yearOffset * 12 + (term + 2) / 2 - 2;
    if (dayOffset < terms[2]) { yearOffset -= 1; } // 如果还没到立春, 年份属于上一年
    solar_calendar reference = solar_creat_date(1899, 2, 4);
    dayOffset = this - reference;
    
    NSInteger idx = ylStemBranchIndexOf(5, 11); // 基准日期年份的天干地支
    idx += yearOffset;
    _year = [YLStemBranch stem:[YLDateUnit unitWith:self.class.stems[idx % 10]
                                                idx:idx % 10]
                        branch:[YLDateUnit unitWith:self.class.branches[idx % 12]
                                                idx:idx % 12]];
    idx = ylStemBranchIndexOf(2, 2); // 基准日期月份的天干地支
    idx += monthOffset;
    _month = [YLStemBranch stem:[YLDateUnit unitWith:self.class.stems[idx % 10]
                                                 idx:idx % 10]
                         branch:[YLDateUnit unitWith:self.class.branches[idx % 12]
                                                 idx:idx % 12]];
    idx = ylStemBranchIndexOf(9, 3); // 基准日期日的天干地支
    idx += dayOffset;
    _day = [YLStemBranch stem:[YLDateUnit unitWith:self.class.stems[idx % 10]
                                               idx:idx % 10]
                       branch:[YLDateUnit unitWith:self.class.branches[idx % 12]
                                               idx:idx % 12]];
    // 日天干
    NSInteger ds = _day.stem.idx;
    NSInteger hour = self.components.hour;
    if (hour >= 23) {
        ds += 1;
        ds %= 10;
    }
    NSInteger b = ((hour + 1) % 24) / 2; // 时地支
    // 当日子时的天干与日天干有关
    // 甲->甲/乙->丙/丙->戊/丁->庚/戊->壬/己->甲/庚->丙/辛->戊/壬->庚/癸->壬
    // 对应到天干的下标就是:
    // 0->0/1->2/2->4/3->6/4->8/5->0/6->2/7->4/8->6/9->8
    NSInteger s = (ds % 5) * 2;
    s += b; // 随着地支推移天干
    s %= 10;
    _hour = [YLStemBranch stem:[YLDateUnit unitWith:self.class.stems[s]
                                                idx:s]
                        branch:[YLDateUnit unitWith:self.class.branches[b]
                                                idx:b]];
    
    // 年飞星，每年 idx--
    // 1864年，idx 为 0, 1899年，idx 为 8
    idx = (yearOffset + 8) % 9;
    idx = (9 - idx) % 9;
    _yearFeixing = [YLDateUnit unitWith:self.class.the9Feixing[idx]
                                    idx:idx];
    
    // 计算吉凶
    // 吉凶的基准日期为 1901-01-01
    // 吉凶计算的规律为：
    // 1. _jx 为 0~11 循环，_jx = 前一天的 _jx+1
    // 2. 若遇到当天为24节气中的节(即 the24Terms 数组中，下标为偶数的节气)，则这一天不 +1
    // 例如：2010-01-04，这一天的 _jx = 4。2010-01-05这一天为小寒(idx = 0), 所以2010-01-05._jx = 2010-01-04._jx = 4
    reference = solar_creat_date(1901, 1, 1);
    dayOffset = this - reference;
    yearOffset = year - 1901;
    idx = term + 1;
    int a = (int)(idx + yearOffset * 24);
    int offsetDayCount = (a + 1) / 2;
    _jx = (5 + dayOffset - offsetDayCount) % 12;
}

@end
