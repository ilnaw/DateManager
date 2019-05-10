//
//  NSString_Custom.m
//  Calendar
//
//  Created by Jasonluo on 11-5-12.
//  Copyright 2011 YouLoft.Com. All rights reserved.
//

#import "NSString_Custom.h"
#import <libkern/OSAtomic.h>


@implementation NSString(Custom)

+(NSString*) ylStringFromNSDate:(NSDate*)date WithFormat:(NSString*)format {
    
    
    static NSMutableDictionary *dic = nil;
    static dispatch_once_t onceToken;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    static OSSpinLock lock;
    dispatch_once(&onceToken, ^{
        dic = [[NSMutableDictionary alloc] init];
        lock = OS_SPINLOCK_INIT;
    });
    OSSpinLockLock(&lock);
    NSDateFormatter *dateFormatter = [dic objectForKey:format];
    if (!dateFormatter)
    {
        dateFormatter = NSDateFormatter.new;
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setCalendar:cal];
        [dateFormatter setDateFormat:format];
        
        [dic setObject:dateFormatter forKey:format];
    }
    OSSpinLockUnlock(&lock);
#pragma clang diagnostic pop
	NSString *strDate = [dateFormatter stringFromDate:date];
	return strDate;
}

@end

