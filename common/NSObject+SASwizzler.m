//
//  NSObject+SASwizzler.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import "NSObject+SASwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "SensorsAnalyticsSDK.h"

static NSString *const kSensorsDataBlackListFileName = @"sensorsdata_black_list";
@implementation NSObject (SASwizzler)

+(BOOL)sensorsdata_swizzleMethod:(SEL)orginalSEL withMethod:(SEL)alternateSEL{
    //获取原始方法
    Method orginalMethod = class_getInstanceMethod(self, orginalSEL);
    //当原始方法不存在时，返回NO，表示SASwizzling失败
    if (!orginalMethod) {
        return NO;
    }
    //获取要交换的方法
    Method alternateMethod = class_getInstanceMethod(self, alternateSEL);
    //当需要交换的方法不存在时，返回NO，表示SASwizzling失败。
    if (!alternateMethod) {
        return NO;
    }
    //交换两个方法实现
    method_exchangeImplementations(orginalMethod, alternateMethod);
    //返回yes,表示SASwizzling成功
    return YES;
}

//黑名单判断
-(BOOL)shouldTrackAppViewScreen{
    static NSSet *blackList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获取黑名单路径
        NSString *path = [[NSBundle bundleForClass:SensorsAnalyticsSDK.class] pathForResource:kSensorsDataBlackListFileName ofType:@"plist"];
        //读取黑名单中的数组
        NSArray *classNames = [NSArray arrayWithContentsOfFile:path];
        NSMutableSet *set = [NSMutableSet setWithCapacity:classNames.count];
        for (NSString *className in classNames) {
            [set addObject:NSClassFromString(className)];
        }
        blackList = [set copy];
    });
    for (Class cla in blackList) {
        //判断当前试图控制器是否为黑名单中的类或者子类
        if ([self isKindOfClass:cla]) {
            return NO;
        }
    }
    return YES;
}
@end
