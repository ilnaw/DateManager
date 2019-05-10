//
//  SQLiteHelper.h
//  SQLiteTest
//
//  Created by Jasonluo on 8/11/11.
//  Copyright 2011 YouLoft Tech. Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface SQLiteHelper : NSObject

+(sqlite3*) openDB:(NSString *)pathName;
+(BOOL) close:(sqlite3*)sqlite;
+(NSArray*) fetchDB:(sqlite3*)SQLite usingSQL:(NSString*)sql;
+(BOOL) updateDB:(sqlite3*)SQLite usingSQL:(NSString*)sql parameters:(NSArray*)parameters;


@end
