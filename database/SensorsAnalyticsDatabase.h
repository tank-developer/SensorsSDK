//
//  SensorsAnalyticsDatabase.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/22.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsDatabase : NSObject
//数据库文件路径
@property (nonatomic,copy,readonly)NSString *filePath;
@property (nonatomic)sqlite3 *database;

//本地事件存储总量
@property (nonatomic)NSUInteger eventCount;

/*
 初始化方法
 @param filePath 数据库路径，如果为nil,使用默认路径
 @param 数据库对象
 */
-(instancetype)initWithFilePath:(nullable NSString *)filePath NS_DESIGNATED_INITIALIZER;

/*
 同步向数据库中插入事件数据
 @param event 事件
 */
-(void)insertEvent:(NSDictionary *)event;

/*
 从数据库中获取事件数据
 @param count 获取的事件数据
 @param return 事件数据
 */
-(NSArray<NSString *> *)selectEventsForCount:(NSUInteger)count;

/*
 从数据库中删除一定量的事件数据
 @param count 需要删除的事件数量
 @param return 是否删除成功
 */
-(BOOL)deleteEventsForCount:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
