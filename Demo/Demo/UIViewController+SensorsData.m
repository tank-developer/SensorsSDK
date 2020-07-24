//
//  UIViewController+SensorsData.m
//  Demo
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UIViewController+SensorsData.h"

#import <SensorsSDK/SensorsSDK.h>
#import <SensorsSDK/SensorsAnalyticsSDK.h>
#import <SensorsSDK/NSObject+SASwizzler.h>

@implementation UIViewController (SensorsData)

//- (void)viewDidAppear:(BOOL)animated{
//    sup
//}

+(void)load{
    [UIViewController sensorsdata_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(sensorsdata_viewDidAppear:)];
}

-(void)sensorsdata_viewDidAppear:(BOOL)animated{
    //调用原始方法，即-viewDidAppear
    [self sensorsdata_viewDidAppear:animated];
    
    if ([self shouldTrackAppViewScreen]) {
        //触发$AppViewScreen事件
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:NSStringFromClass([self class]) forKey:@"$screen_name"];
        
        //navigationItem 的优先级高于navigationItem.title
        NSString *title = [self contentFromView:self.navigationItem.titleView];
        if (title.length == 0) {
            title = self.navigationItem.title;
        }
        [[SensorsAnalyticsSDK sharedInstance] track:@"$AppViewScreen" properties:properties];
        
    }
    
//    if ([self shouldTrackAppViewScreen]) {
//
//    }
    
}
//获取标题
-(NSString *)contentFromView:(UIView *)rootView{
    if (rootView.isHidden) {
        return nil;
    }
    NSMutableString *elementContent = [NSMutableString string];
    if ([rootView isKindOfClass:[UIView class]]) {
        UIButton *button = (UIButton *)rootView;
        NSString *title = button.titleLabel.text;
        if (title.length > 0) {
            [elementContent appendString:title];
        }
    }else if ([rootView isKindOfClass:[UILabel class]]){
        UILabel *label = (UILabel *)rootView;
        NSString *title = label.text;
        if (title.length > 0) {
            [elementContent appendString:title];
        }
    }else if ([rootView isKindOfClass:[UITextView class]]){
        UITextView *textView = (UITextView *)rootView;
        NSString *title = textView.text;
        if (title.length > 0) {
            [elementContent appendString:title];
        }
    }else{
        NSMutableArray<NSString *> *elementContentArray = [NSMutableArray array];
        for (UIView *subView in rootView.subviews) {
            NSString *temp = [self contentFromView:subView];
            if (temp.length > 0) {
                [elementContentArray addObject:temp];
            }
        }
        if (elementContentArray.count > 0) {
            [elementContent appendString:[elementContentArray componentsJoinedByString:@"-"]];
        }
    }
    return [elementContent copy];
}

@end
