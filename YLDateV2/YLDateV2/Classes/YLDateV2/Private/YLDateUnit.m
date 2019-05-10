//
//  YLDateUnit.m
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/22.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import "YLDateUnit.h"

@implementation YLDateUnit {
    NSString *_backStore;
}

+ (instancetype)unitWith:(NSString *)name
                     idx:(NSInteger)idx {
    YLDateUnit *unit = YLDateUnit.new;
    unit->_backStore = name;
    unit->_idx = idx;
    return unit;
}

#pragma mark - Override
- (NSUInteger)length {
    return self->_backStore.length;
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [self->_backStore characterAtIndex:index];
}

- (void)getCharacters:(unichar *)buffer
                range:(NSRange)range {
    [self->_backStore getCharacters:buffer
                              range:range];
}

@end

NSInteger ylStemBranchIndexOf(NSInteger stem, NSInteger branch) {
    NSInteger delta = (stem - branch) / 2;
    if (delta >= 0) { return delta * 10 + stem; }
    return 60 + delta * 12 + branch;
}

@implementation YLStemBranch

+ (instancetype)stem:(YLDateUnit *)stem
              branch:(YLDateUnit *)branch {
    YLStemBranch *sb = YLStemBranch.new;
    sb->_stem = stem;
    sb->_branch = branch;
    return sb;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@", self.stem, self.branch];
}

@end

@implementation YLTermTime

+ (instancetype)termTimeWith:(NSInteger)hour
                      minute:(NSInteger)minute
                      second:(NSInteger)second {
    YLTermTime *time = YLTermTime.new;
    time->_hour = hour;
    time->_minute = minute;
    time->_second = second;
    return time;
}

@end

@implementation YLYiJi

+ (instancetype)yi:(NSString *)yi
                ji:(NSString *)ji {
    YLYiJi *yj = YLYiJi.new;
    yj->_yi = yi;
    yj->_ji = ji;
    return yj;
}

@end
