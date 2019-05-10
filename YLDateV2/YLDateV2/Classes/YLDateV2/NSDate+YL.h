//
//  NSDate+YL.h
//  Calendar_New_UI
//
//  Created by zwh on 2019/3/11.
//  Copyright © 2019 YouLoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLDateV2.h"

NS_ASSUME_NONNULL_BEGIN

/**
 NSDate分类
 --by zwh
 */
@interface NSDate (YL)

/** 获取 YLDateV2 实例 */
@property (nonatomic, strong, readonly) YLDateV2 *yl;

@end

NS_ASSUME_NONNULL_END
