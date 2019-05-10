//
//  YLAlmanac+DataProvider.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/9.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLAlmanac.h"
#import "YLSAADB.h"

@implementation YLAlmanac (DataProvider)

- (YLYiJi *)yiJi {
    YLYiJi *yj = self->_dataProvider[NSStringFromSelector(_cmd)];
    if (!yj) {
        NSInteger gz = ylStemBranchIndexOf(self.day.stem.idx, self.day.branch.idx);
        YLYJDataEntity *entity = [YLSAADB queryYJData:self->_jx
                                                   gz:gz];
        yj = [YLYiJi yi:entity.yi
                     ji:entity.ji];
        self->_dataProvider[NSStringFromSelector(_cmd)] = yj;
    }
    return yj;
}

- (YLYiJi *)xiongJiShen {
    YLYiJi *jishen = self->_dataProvider[NSStringFromSelector(_cmd)];
    if (!jishen) {
        __block YLYiJi *xj = nil;
        [YLSAADB syncConnectTo:^(FMDatabase * _Nonnull db) {
            int code = (self.month.branch.idx + 10) % 12 + 1;
            NSString *sql = [NSString stringWithFormat:@"SELECT favonian AS Y, terrible AS J FROM advices WHERE Code = %d AND dayGz = '%@'", code, self.day];
            FMResultSet *set = [db executeQuery:sql];
            if (set.next) {
                xj = [YLYiJi yi:[set stringForColumn:@"Y"]
                             ji:[set stringForColumn:@"J"]];
            }
        }];
        jishen = xj;
        self->_dataProvider[NSStringFromSelector(_cmd)] = jishen;
    }
    return jishen;
}

- (NSArray<YLAlmanacTime *> *)almanacTimes {
    NSArray<YLAlmanacTime *> *almanacTimes = self->_dataProvider[NSStringFromSelector(_cmd)];
    if (!almanacTimes) {
        NSMutableArray<YLAlmanacTime *> *times = NSMutableArray.new;
        NSInteger ds = self.day.stem.idx;
        for (int i = 0; i < 12; i++) {
            NSInteger s = (ds % 5) * 2;
            s += i;
            s %= 10;
            YLStemBranch *hour = [YLStemBranch stem:[YLDateUnit unitWith:self.class.stems[s]
                                                                     idx:s]
                                             branch:[YLDateUnit unitWith:self.class.branches[i]
                                                                     idx:i]];
            YLAlmanacTime *time = [YLAlmanacTime timeWith:hour
                                                    inDay:self.day];
            [times addObject:time];
        }
        almanacTimes = times.copy;
        self->_dataProvider[NSStringFromSelector(_cmd)] = almanacTimes;
    }
    return almanacTimes;
}

- (NSString *)zhiShenExplain {
    NSString *explain = self->_explains[NSStringFromSelector(_cmd)];
    if (!explain) {
        explain = [YLSAADB explain:self.zhiShen];
        self->_explains[NSStringFromSelector(_cmd)] = explain;
    }
    return explain;
}

- (NSString *)jianChuExplain {
    NSString *explain = self->_explains[NSStringFromSelector(_cmd)];
    if (!explain) {
        explain = [YLSAADB explain:[NSString stringWithFormat:@"%@日", self.jianChu]];
        self->_explains[NSStringFromSelector(_cmd)] = explain;
    }
    return explain;
}

- (NSString *)starExplain {
    NSString *explain = self->_explains[NSStringFromSelector(_cmd)];
    if (!explain) {
        explain = [YLSAADB explain:self.star];
        self->_explains[NSStringFromSelector(_cmd)] = explain;
    }
    return explain;
}

- (NSString *)fetusExplain {
    NSString *explain = self->_explains[NSStringFromSelector(_cmd)];
    if (!explain) {
        explain = [YLSAADB explain:self.fetus];
        self->_explains[NSStringFromSelector(_cmd)] = explain;
    }
    return explain;
}

@end

@implementation YLAlmanacTime (DataProvider)

- (YLYiJi *)yiJi {
    YLYiJi *yj = self->_dataProvider[NSStringFromSelector(_cmd)];
    if (!yj) {
        NSInteger gz = ylStemBranchIndexOf(self->_day.stem.idx, self->_day.branch.idx);
        gz++;
        __block YLYiJi *query = nil;
        [YLSAADB syncConnectTo:^(FMDatabase * _Nonnull db) {
            int hour = (int)self.hour.branch.idx;
            NSString *sql = [NSString stringWithFormat:@"SELECT Y%d AS Y, J%d AS J FROM TimesYJ WHERE gz = %d", hour, hour, (int)gz];
            FMResultSet *set = [db executeQuery:sql];
            if (set.next) {
                query = [YLYiJi yi:[set stringForColumn:@"Y"]
                                ji:[set stringForColumn:@"J"]];
            }
        }];
        yj = query;
        self->_dataProvider[NSStringFromSelector(_cmd)] = yj;
    }
    return yj;
}

@end
