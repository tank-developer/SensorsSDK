//
//  SensorsAnalyticsNetwork.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/23.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsNetwork : NSObject
//数据上报的URL地址
@property (nonatomic,strong)NSURL *serverURL;
/*
 指定初始化方法
 @param serverURL 服务器URL地址
 @param 初始化对象
 */
-(instancetype)initWithServerURL:(NSURL *)serverURL NS_DESIGNATED_INITIALIZER;

/*
 禁止直接使用-init方法进行初始化
 */
-(instancetype)init NS_UNAVAILABLE;

/*
同步数据
@param events 事件数组
@param yes:同步成功；no：同步失败
*/
-(BOOL)flushEvents:(NSArray<NSString *> *)events;

@end

NS_ASSUME_NONNULL_END
