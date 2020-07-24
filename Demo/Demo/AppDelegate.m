//
//  AppDelegate.m
//  Demo
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//
/*
 UILongPressGestureRecognizer，这个的实现有问题
 UITableView 和 UICollectionView获取当前VC，获取不准确
 p158 全埋点事件时长
 */

#import "AppDelegate.h"
#import <SensorsSDK/SensorsSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [SensorsAnalyticsSDK sharedInstance];
//    [[SensorsAnalyticsSDK sharedInstance] track:@"MyFirstEvent" properties:@{@"testKey":@"testValue"}];
//    [[SensorsAnalyticsSDK sharedInstance] login:@"1234"];
    
    //初始化埋点SDK
    [SensorsAnalyticsSDK startWithServerURL:@"URL"];
    //触发事件
    [[SensorsAnalyticsSDK sharedInstance] track:@"MyFirstEvent" properties:@{@"testKey":@"testValue"}];
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
