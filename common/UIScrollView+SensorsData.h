//
//  UIScrollView+SensorsData.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorsAnalyticsDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SensorsData)
@property (nonatomic,strong)SensorsAnalyticsDelegateProxy *sensorsdata_delegateProxy;
@end

NS_ASSUME_NONNULL_END
