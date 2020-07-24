//
//  SensorsAnalyticsKeychainItem.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/21.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsKeychainItem : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithService:(NSString *)service key:(NSString *)key;
-(instancetype)initWithService:(NSString *)service accessGroup:(nullable NSString *)accessGroup key:(NSString *)key NS_DESIGNATED_INITIALIZER;
-(nullable NSString *)value;
-(void)update:(NSString *)value;
-(void)remove;
@end

NS_ASSUME_NONNULL_END
