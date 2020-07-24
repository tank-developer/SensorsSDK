//
//  UIView+SensorsData.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SensorsData)

//控件类型
@property (nonatomic,copy,readonly)NSString *sensorsdata_elementType;
//控件内容
@property (nonatomic,copy,readonly)NSString *sensorsdata_elementContent;

@property (nonatomic,readonly)UIViewController *sensorsdata_viewController;


@end

#pragma mark - UIButton
@interface UIButton (SensorsData)

@end

#pragma mark - UISwitch
@interface UISwitch (SensorsData)

@end

#pragma mark - UISlider
@interface UISlider (SensorsData)

@end

NS_ASSUME_NONNULL_END
