//
//  UIGestureRecognizer+SensorsData.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UIGestureRecognizer+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import "SensorsAnalyticsSDK.h"

@implementation UIGestureRecognizer (SensorsData)

+(void)load{
    [UITapGestureRecognizer sensorsdata_swizzleMethod:@selector(initWithTarget:action:) withMethod:@selector(sensorsdata_initWithTarget:action:)];
    [UITapGestureRecognizer sensorsdata_swizzleMethod:@selector(addTarget:action:) withMethod:@selector(sensorsdata_addTarget:action:)];
}

-(instancetype)sensorsdata_initWithTarget:(id)target action:(SEL)action{
    //调用原始的初始化方法进行对象初始化
    [self sensorsdata_initWithTarget:target action:action];
    //调用添加target -Action的方法，添加埋点的target -Action
    //这里其实调用的是-sensorsdata_addTarget:action的实现方法，因为已经进行交换
    [self addTarget:target action:action];
    return self;
}
-(void)sensorsdata_addTarget:(id)target action:(SEL)action{
    //调用原始的方法，添加target -Action
    [self sensorsdata_addTarget:target action:action];
    //新增target -Action，用于触发$AppClick事件
    [self sensorsdata_addTarget:self action:@selector(sensorsdata_trackTapGestureAction:)];
}

-(void)sensorsdata_trackTapGestureAction:(UITapGestureRecognizer *)sender{
    //获取收拾识别器的控件
    UIView *view = sender.view;
    //暂定只采集UILabel和UIImageView
    BOOL isTrackClass = [view isKindOfClass:UILabel.class] || [view isKindOfClass:UIImageView.class];
    if (!isTrackClass) {
        return;
    }
    //触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:view properties:nil];
}

@end


#pragma mark - UILongPressGestureRecognizer
@implementation UILongPressGestureRecognizer (SensorsData)

//+(void)load{
//    [UILongPressGestureRecognizer sensorsdata_swizzleMethod:@selector(initWithTarget:action:) withMethod:@selector(sensorsdata_initWithTarget:action:)];
//    [UILongPressGestureRecognizer sensorsdata_swizzleMethod:@selector(addTarget:action:) withMethod:@selector(sensorsdata_addTarget:action:)];
//}
//-(instancetype)sensorsdata_initWithTarget:(id)target action:(SEL)action{
//    //调用原始的初始化方法进行对象初始化
//    [self sensorsdata_initWithTarget:target action:@selector(action)];
//    //调用添加target-action的方法，添加埋点的target-action
//    //这里其实调用的是-sensorsdata_addtarget:action的实现方法，因为已经进行交换
//    [self addTarget:target action:action];
//    return self;
//}
//-(void)sensorsdata_addTarget:(id)target action:(SEL)action{
//    [self sensorsdata_addTarget:target action:action];
//    [self sensorsdata_addTarget:self action:@selector(sensorsdata_trackLongPressGestureAction:)];
//}
//-(void)sensorsdata_trackLongPressGestureAction:(UILongPressGestureRecognizer *)sender{
//    UIView *view = sender.view;
//    BOOL isTrackClass = [view isKindOfClass:UILabel.class] || [view isKindOfClass:UIImageView.class];
//    if (!isTrackClass) {
//        return;
//    }
//    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:view properties:nil];
//}

@end



