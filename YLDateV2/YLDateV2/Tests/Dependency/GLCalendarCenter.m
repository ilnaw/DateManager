//
//  GLCalendarCenter.m
//  GLCalendarHL
//
//  Created by gaolong on 15-1-16.
//  Copyright (c) 2015年 Nineton Tech Co., Ltd. All rights reserved.
//

#import "GLCalendarCenter.h"

static GLCalendarCenter* center = nil;
@implementation GLCalendarCenter

+(GLCalendarCenter*)sharedInstance{
    if (center==nil) {
        center = [[GLCalendarCenter alloc]init];
        center.gelonCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSCalendar* currentCalendar = [NSCalendar currentCalendar];
        if ([currentCalendar.calendarIdentifier isEqualToString:NSCalendarIdentifierGregorian]) {
            center.isStandardCalendar = YES;
        }else{
            center.isStandardCalendar = NO;
        }
    }
    return center;
}

@end
