//
//  UIScrollView+SensorsData.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UIScrollView+SensorsData.h"
#import <objc/runtime.h>
@implementation UIScrollView (SensorsData)
-(void)setSensorsdata_delegateProxy:(SensorsAnalyticsDelegateProxy *)sensorsdata_delegateProxy{
    objc_setAssociatedObject(self, @selector(setSensorsdata_delegateProxy:), sensorsdata_delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(SensorsAnalyticsDelegateProxy *)sensorsdata_delegateProxy{
    return objc_getAssociatedObject(self, @selector(sensorsdata_delegateProxy));
}
@end
