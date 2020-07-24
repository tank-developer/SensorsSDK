//
//  UICollectionView+SensorsData.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UICollectionView+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import "SensorsAnalyticsDelegateProxy.h"
#import "UIScrollView+SensorsData.h"

@implementation UICollectionView (SensorsData)

+(void)load{
    [UICollectionView sensorsdata_swizzleMethod:@selector(setDelegate:) withMethod:@selector(sensorsdata_setDelegate:)];
}

-(void)sensorsdata_setDelegate:(id<UICollectionViewDelegate>)delegate{
    SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy proxyWithCollectionViewDelegate:delegate];
    self.sensorsdata_delegateProxy = proxy;
    [self sensorsdata_setDelegate:proxy];
}
@end
