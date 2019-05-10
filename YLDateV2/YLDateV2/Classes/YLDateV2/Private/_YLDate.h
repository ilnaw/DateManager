//
//  _YLDate.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLDateCapability.h"

NS_ASSUME_NONNULL_BEGIN

/**
 日期类基类。不直接使用
 --by zwh
 */
@interface _YLDate : NSObject <YLDateCapability> {
    @protected
    NSDate *_date;
    NSDateComponents *_components;
}

/** 格利高里历。单例 */
@property (class, nonatomic, strong, readonly) NSCalendar *calendar;

/** 获取默认的DateComponents */
+ (NSDateComponents *)componentsFromDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
