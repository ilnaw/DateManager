//
//  YLSAAModel.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/4/8.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLSAAModel.h"

@implementation YLSAAIndexEntity

+ (instancetype)entityByResult:(FMResultSet *)set {
    YLSAAIndexEntity *entity = YLSAAIndexEntity.new;
    entity->__Date = [set stringForColumn:@"_Date"];
    entity->_jx = [set intForColumn:@"jx"];
    entity->_gz = [set intForColumn:@"gz"];
    return entity;
}

@end

@implementation YLYJDataEntity

+ (instancetype)entityByResult:(FMResultSet *)set {
    YLYJDataEntity *entity = YLYJDataEntity.new;
    entity->_jx = [set intForColumn:@"jx"];
    entity->_gz = [set intForColumn:@"gz"];
    entity->_ji = [set stringForColumn:@"ji"];
    entity->_yi = [set stringForColumn:@"yi"];
    return entity;
}

@end
