//
//  SensorsAnalyticsFileStore.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/22.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsFileStore : NSObject

@property (nonatomic,copy)NSString *filePath;
/*
 将事件保存到文件中
 @param event 事件数据
 */
-(void)saveEvent:(NSDictionary *)event;

@property (nonatomic,copy,readonly)NSArray<NSDictionary *> *allEvents;

/*
 根据数量删除本地保存的事件数据
 @param count 需要删除的事件数量
 */
-(void)deleteEventsForCount:(NSInteger )count;

//本地可最大缓存事件条数
@property (nonatomic)NSUInteger maxLocalEventCount;


@end

NS_ASSUME_NONNULL_END
