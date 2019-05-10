//
//  AppDelegate.m
//  YLDateV2
//
//  Created by zwh on 2019/4/24.
//  Copyright © 2019 zwh. All rights reserved.
//

#import "AppDelegate.h"
#import "YLDateV2.h"
#import "YLSAADB.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSDateComponents *components = [[NSDateComponents alloc]init];
//    components.year = 2019;
//    components.month = 4;
//    components.day = 30;
//    components.hour = 14;
//    components.minute = 12;
//    components.second = 33;
    NSMutableArray *yijiArray = NSMutableArray.new;
    YLDateV2 *date = [YLDateV2 dateFromString:@"2019-04-30" format:@"yyyy-MM-dd"];
    NSArray *yi = [date.almanac.yiJi.yi componentsSeparatedByString:@" "];
    NSMutableArray *yiArray = NSMutableArray.new;
    for (NSString *y in yi) {
        [yiArray addObject:@{ @"key" : y , @"value" : [YLSAADB explain:y] ? : @""}];
    }
    [yijiArray addObject:yiArray];
    
    NSMutableArray *jiArray = NSMutableArray.new;
    NSArray *ji = [date.almanac.yiJi.ji componentsSeparatedByString:@" "];
    for (NSString *j in ji) {
        [jiArray addObject:@{ @"key" : j , @"value" : [YLSAADB explain:j] ? : @""}];
    }
    
    [yijiArray addObject:jiArray];
    NSLog(@"--%@",yijiArray);
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
