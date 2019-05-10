//
//  YLDBEntity.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/4.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDBEntity.h"

@implementation YLDBEntity

+ (instancetype)entityByResult:(FMResultSet *)set {
#ifdef DEBUG
    NSAssert(NO, @"Subclass should implement!");
#endif
    return nil;
}

@end
