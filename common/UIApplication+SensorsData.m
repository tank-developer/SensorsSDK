//
//  UIApplication+SensorsData.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UIApplication+SensorsData.h"
#import "SensorsAnalyticsSDK.h"
#import "NSObject+SASwizzler.h"
#import <UIView+SensorsData.h>

@implementation UIApplication (SensorsData)

+(void)load{
    [UIApplication sensorsdata_swizzleMethod:@selector(sendAction:to:from:forEvent:) withMethod:@selector(sensordata_sendAction:to:from:forEvent:)];
}

-(BOOL)sensordata_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event{
    //获取控件类型的old方法
//    UIView *view = (UIView *)sender;
//    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
//    //获取控件类型
//    properties[@"$element_type"] = view.sensorsdata_elementType;
//    //触发$AppClick事件
//    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppClick" properties:properties];
    
    //指明只触发UITouchPhaseEnded才出发appClick
    if ([sender isKindOfClass:UISwitch.class] || [sender isKindOfClass:UISegmentedControl.class] || [sender isKindOfClass:UIStepper.class]|| event.allTouches.anyObject.phase == UITouchPhaseEnded) {
        [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:sender properties:nil];
    }
    //调用原有实现，即- sendAction:to:from:forEvent:方法
    return [self sensordata_sendAction:action to:target from:sender forEvent:event];
}

@end
