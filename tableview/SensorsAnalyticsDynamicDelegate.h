//
//  SensorsAnalyticsDynamicDelegate.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsDynamicDelegate : NSObject
+(void)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
