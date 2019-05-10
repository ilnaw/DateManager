//
//  YLDateCapability.h
//  CalendarOS7
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#ifndef YLDateCapability_h
#define YLDateCapability_h

/**
 日期类共性
 --by zwh
 */
@protocol YLDateCapability <NSObject>

/** 使用 NSDate 初始化 */
+ (instancetype)dateWithDate:(NSDate *)date;

/** 日期 */
@property (nonatomic, copy, readonly) NSDate *date;
/** 日期组件 */
@property (nonatomic, copy, readonly) NSDateComponents *components;

@end

#endif /* YLDateCapability_h */
