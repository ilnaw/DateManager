//
//  YLHuangliDetailDB.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/4.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLHuangliDetailDB.h"

@implementation YLHuangliDetailDB

+ (NSString *)dbPath { return [[NSBundle mainBundle] pathForResource:@"HuangliDetails" ofType:@"db"]; }
+ (dispatch_queue_t)dbQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.wnl.huangli.detail.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (NSArray<NSString *> *)queryZhishenDetailByName:(NSString *)name {
    NSMutableArray<NSString *> *detail = NSMutableArray.new;
    [self syncConnectTo:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM JiShenExp WHERE '%@' LIKE '%%'||name||'%%'", name];
        FMResultSet *set = [db executeQuery:sql];
        while (set.next) {
            
        }
    }];
    return detail.copy;
}

@end
