//
//  SensorsAnalyticsDelegateProxy.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsDelegateProxy : NSProxy<UICollectionViewDelegate,UITableViewDelegate>
+(instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;

+(instancetype)proxyWithCollectionViewDelegate:(id<UICollectionViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
