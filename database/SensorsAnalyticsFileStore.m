//
//  SensorsAnalyticsFileStore.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/22.
//  Copyright © 2020 Company. All rights reserved.
//

#import "SensorsAnalyticsFileStore.h"

//默认文件名
static NSString *const SensorsAnalyticsDefaultFileName = @"SensorsAnalyticsData.plist";


@interface SensorsAnalyticsFileStore ()
@property (nonatomic,strong)NSMutableArray<NSDictionary *> *events;

@property (nonatomic,strong) dispatch_queue_t queue;

@end

@implementation SensorsAnalyticsFileStore

-(NSArray<NSDictionary *> *)allEvents{
    __block NSArray<NSDictionary *> *allEvents = nil;
    dispatch_async(self.queue, ^{
        allEvents = [self.events copy];
    });
    return [self.events copy];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化默认的事件数据存储地址
        _filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:SensorsAnalyticsDefaultFileName];
        NSLog(@"文件存储路径filePath:%@",_filePath);
        //初始化数据，后面会先读取本地保存的数据数据
//        _events = [[NSMutableArray alloc]init];
        
        
        //初始化队列的唯一标示
        NSString *label = [NSString stringWithFormat:@"cn.sensorsdata.serialQueue.%p",self];
        //创建一个serial类型的queue,即FIFO
        _queue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        
        //从文件路径中读取数据
        [self readAllEventsFromFilePath:_filePath];
        
        //初始化本地最大缓存事件条数
        _maxLocalEventCount = 1000;
    }
    return self;
}

-(void)saveEvent:(NSDictionary *)event{
    dispatch_async(self.queue, ^{
        //如果当前事件条数超过最大值，删除最旧的事件
        if (self.events.count >= self.maxLocalEventCount) {
            [self.events removeObjectAtIndex:0];
        }
        
        //在数组中直接添加事件数据
        [self.events addObject:event];
        [self writeEventsToFile];
    });

}

-(void)writeEventsToFile{
    //JSON 解析错误信息
    NSError *error = nil;
    if (self.events == nil) {
        return;
    }
    //将字典数据解析成JSON数据
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.events options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return NSLog(@"the json object serialization error:%@",error);
    }
    //将数据写入文件
    [data writeToFile:self.filePath atomically:YES];
}
-(void)readAllEventsFromFilePath:(NSString *)filePath{
    dispatch_async(self.queue, ^{
        //从文件中读取路径
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data == nil) {
            return;
        }
        //解析在文件中读取的JSON数据
        NSMutableArray *allEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //将文件中的数据保存在内存中
        self.events = allEvents ?: [NSMutableArray array];
    });
    
//    //从文件中读取路径
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    if (data) {
//        //解析在文件中读取的JSON数据
//        NSMutableArray *allEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        //将文件中的数据保存在内存中
//        self.events = allEvents ?: [NSMutableArray array];
//    }else{
//        self.events = [NSMutableArray array];
//    }
    
}
-(void)deleteEventsForCount:(NSInteger )count{
    
    dispatch_async(self.queue, ^{
        //删除前count条事件数据
        [self.events removeObjectsInRange:NSMakeRange(0, count)];
        //将删除后的剩余的事件数据保存到文件中
        [self writeEventsToFile];
    });

}
@end
