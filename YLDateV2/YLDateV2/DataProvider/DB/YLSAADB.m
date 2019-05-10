//
//  YLSAADB.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/8.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLSAADB.h"

@implementation YLSAADB


+ (NSString *)dbPath { return [[NSBundle mainBundle] pathForResource:@"saa" ofType:@"db"]; }
+ (dispatch_queue_t)dbQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.wnl.saa.db.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (YLSAAIndexEntity *)queryIndexTableEntity:(NSString *)_Date {
    __block YLSAAIndexEntity *entity;
    [self syncConnectTo:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM IndexTable WHERE _Date = '%@'", _Date];
        FMResultSet *set = [db executeQuery:sql];
        if (set.next) {
            entity = [YLSAAIndexEntity entityByResult:set];
        }
    }];
    return entity;
}

+ (NSString *)explain:(NSString *)ancient {
    __block NSString *explain = nil;
    [self syncConnectTo:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM explain WHERE ancient = '%@'", ancient];
        FMResultSet *set = [db executeQuery:sql];
        if (set.next) {
            explain = [set stringForColumn:@"prose"];
        }
    }];
    return explain;
}

+ (YLYJDataEntity *)queryYJData:(NSInteger)jx
                             gz:(NSInteger)gz {
    __block YLYJDataEntity *entity = nil;
    [self syncConnectTo:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM YJData WHERE jx = %d AND gz = %d", (int)jx, (int)gz];
        FMResultSet *set = [db executeQuery:sql];
        if (set.next) {
            entity = [YLYJDataEntity entityByResult:set];
        }
    }];
    return entity;
}

@end
