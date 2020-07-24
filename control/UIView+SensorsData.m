//
//  UIView+SensorsData.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UIView+SensorsData.h"

@implementation UIView (SensorsData)

-(NSString *)sensorsdata_elementType{
    return NSStringFromClass([self class]);
}

-(NSString *)sensorsdata_elementContent{
//    return nil;
    //如果是隐藏控件，不获取控件内容
    if (self.isHidden || self.alpha == 0) {
        return nil;
    }
    //初始化数组，用于保存子控件的内容
    NSMutableArray *contents = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        //获取子控件的内容
        //如果子类有内容，例如uialbel的text，就获取text属性
        //如果子类没有内容，就递归调用该方法，获取其子控件的内容
        NSString *content = view.sensorsdata_elementContent;
        if (content.length > 0) {
            [contents addObject:content];
        }
    }
    return contents.count == 0 ? nil:[contents componentsJoinedByString:@"-"];
}
-(UIViewController *)sensorsdata_viewController{
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    //如果没找到返回nil
    return nil;
}
@end

#pragma mark - UIButton
@implementation  UIButton(SensorsData)

-(NSString *)sensorsdata_elementContent{
//    return self.titleLabel.text;
    return self.currentTitle ?: super.sensorsdata_elementContent;
}
@end

#pragma mark - UILabel
@implementation  UILabel(SensorsData)
-(NSString *)sensorsdata_elementContent{
    return self.text ?: super.sensorsdata_elementContent;
}
@end

#pragma mark - UISwitch
@implementation  UISwitch(SensorsData)

-(NSString *)sensorsdata_elementContent{
    return self.on ? @"checked" : @"unchecked";
}
@end

#pragma mark - UISlider
@implementation  UISlider(SensorsData)
-(NSString *)sensorsdata_elementContent{
    return [NSString stringWithFormat:@"%.2f",self.value];
}
@end


