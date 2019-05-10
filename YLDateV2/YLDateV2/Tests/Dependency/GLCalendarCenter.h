//
//  GLCalendarCenter.h
//  GLCalendarHL
//
//  Created by gaolong on 15-1-16.
//  Copyright (c) 2015年 Nineton Tech Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLCalendarCenter : NSObject

@property(nonatomic,assign) BOOL isStandardCalendar;
@property(nonatomic,strong) NSCalendar* gelonCalendar;

+(GLCalendarCenter*)sharedInstance;

@end
