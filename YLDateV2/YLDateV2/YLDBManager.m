//
//  YLDBManager.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/12.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDBManager.h"

@implementation YLDBManager

+ (NSString *)dbPath { return nil; }
+ (Class)databaseClass { return FMDatabase.class; }
+ (dispatch_queue_t)dbQueue { return nil; }

+ (void)asyncConnectTo:(void (^)(FMDatabase *db))action
                  done:(void (^)(void))done {
    [self _connect:action
           isAsync:YES
              done:done];
}

+ (void)syncConnectTo:(void (^)(FMDatabase *db))action {
    [self _connect:action
           isAsync:NO
              done:nil];
}

#pragma mark - Private
+ (void)_connect:(void (^)(FMDatabase *db))action
         isAsync:(BOOL)isAsync
            done:(void (^)(void))done {
    FMDatabase *db = [self.databaseClass databaseWithPath:self.dbPath];
    dispatch_queue_t queue = self.dbQueue;
    if (!queue) { return; }
    
    void (^block)(void) = ^{
        if ([db open]) {
            if (action) { action(db); }
            [db close];
        }
        if (isAsync && done) { done(); }
    };
    
    isAsync ? dispatch_async(queue, block) : dispatch_sync(queue, block);
}

@end
