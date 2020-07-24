//
//  NSObject+SASwizzler.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface NSObject (SASwizzler)
/*
交换方法名为orginalSEL和方法名为alternateSEL两个方法的实现

*/
+(BOOL)sensorsdata_swizzleMethod:(SEL)orginalSEL withMethod:(SEL)alternateSEL;

//黑名单判断
-(BOOL)shouldTrackAppViewScreen;
@end

NS_ASSUME_NONNULL_END
