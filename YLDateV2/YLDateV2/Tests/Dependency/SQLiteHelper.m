//
//  SQLiteHelper.m
//  SQLiteTest
//
//  Created by Jasonluo on 8/11/11.
//  Copyright 2011 YouLoft Tech. Co.,Ltd All rights reserved.
//

#import "SQLiteHelper.h"
//#import "Custom.h"
#import "NSString_Custom.h" // 只用了NSString+Custom里面的方法，不需要加入Custom头文件
#import "YLDate.h"          // 形成了相互依赖，强耦合

@implementation SQLiteHelper

+(sqlite3*) openDB:(NSString *)pathName {
	sqlite3 *database = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL find = [fileManager fileExistsAtPath:pathName];
    if (find) {
        @try {
            if(SQLITE_OK != sqlite3_open([pathName UTF8String], &database)) {
                sqlite3_close(database);
                return nil;
            }
        }
        @catch (NSException *exception) {
            ;
        }
       
        return database;
    }
    return nil;	
}
+(BOOL) close:(sqlite3*)sqlite {
	if (SQLITE_OK == sqlite3_close(sqlite)) {
		return YES;
	}
	return NO;
}
+(NSArray*) fetchDB:(sqlite3*)SQLite usingSQL:(NSString*)sql {
	NSMutableArray *fetchResult = [NSMutableArray array];
	sqlite3_stmt *statement = nil;
	if (SQLITE_OK != sqlite3_prepare_v2(SQLite, [sql UTF8String], -1, &statement, NULL)) {
	}
	while (SQLITE_ROW == sqlite3_step(statement)) {
		NSMutableDictionary *item = [NSMutableDictionary dictionary];
		for (int i=0; i<sqlite3_column_count(statement); i++) {
			NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
			NSObject *columnValue = nil;
			int type = sqlite3_column_type(statement, i);
			switch (type) {
				case 1://SQLITE_INTEGER
					columnValue = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, i)];
					break;
				case 2://SQLITE_FLOAT
					columnValue = [NSNumber numberWithDouble:(double)sqlite3_column_double(statement, i)];
					break;
				case 3://SQLITE_TEXT
					columnValue = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, i)];
					break;
				case 4: {//SQLITE_BLOB
					Byte* data = (Byte*)sqlite3_column_blob(statement, i);
					int length = (int)sqlite3_column_int(statement, i+1);
					columnValue = [NSData dataWithBytes:data length:length];
					break;
				}
				case 5://SQLITE_NULL
					columnValue = @"";
					break;
				default:
					columnValue = @"";
					break;
			}
			[item setObject:columnValue forKey:columnName];
		}
		[fetchResult addObject:item];
   }
    sqlite3_finalize(statement);
	return fetchResult;
}
+(BOOL) updateDB:(sqlite3*)SQLite usingSQL:(NSString*)sql parameters:(NSArray*)parameters {	
    sqlite3_stmt *statement = nil;
    //static char *sql = "INSERT INTO channels (cid,title,imageData,imageLen)VALUES(?,?,?,?)";
	//问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。
    if (SQLITE_OK != sqlite3_prepare_v2(SQLite, [sql UTF8String], -1, &statement, NULL)) {
        return NO;
    }
	for (int i=0; i<[parameters count]; i++) {
		NSObject *parameter = [parameters objectAtIndex:i];
		if ([parameter isKindOfClass:[NSString class]]) {
			sqlite3_bind_text(statement, i+1, [(NSString*)parameter UTF8String], -1, SQLITE_TRANSIENT);
		}
		else if ([parameter isKindOfClass:[NSNumber class]]) {
			sqlite3_bind_double(statement, i+1, [(NSNumber*)parameter doubleValue]);
		}
		else if ([parameter isKindOfClass:[NSData class]]) {
			sqlite3_bind_blob(statement, i+1, [(NSData*)parameter bytes], (int)[(NSData*)parameter length], SQLITE_TRANSIENT);
		}
		else if ([parameter isKindOfClass:[NSDate class]]) {
			sqlite3_bind_text(statement, i+1, [[NSString ylStringFromNSDate:(NSDate*)parameter WithFormat:@"yyyy-MM-dd HH:mm"] UTF8String], -1, SQLITE_TRANSIENT);
		}else if ([parameter isKindOfClass:[YLDate class]]) {
			sqlite3_bind_text(statement, i+1, [[NSString ylStringFromNSDate:((YLDate*)parameter).date WithFormat:@"yyyy-MM-dd HH:mm"] UTF8String], -1, SQLITE_TRANSIENT);
		}
	}
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
	
    if (success == SQLITE_ERROR) {
        return NO;
    }
    return YES;
}

@end
