//
//  SensorsAnalyticsSDK.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import "SensorsAnalyticsSDK.h"
#include <sys/sysctl.h>
#import "UIView+SensorsData.h"
#import "SensorsAnalyticsKeychainItem.h"
#import "SensorsAnalyticsFileStore.h"
#import "SensorsAnalyticsDatabase.h"
#import "SensorsAnalyticsNetwork.h"
#import "SensorsAnalyticsExceptionHandler.h"


static NSString *const SensorsAnalyticsVersion = @"1.0.0";
static NSString *const SensorsAnalyticsAnonymousId = @"cn.sensorsdata.anonymous_id";

static NSString *const SensorsAnalyticsKeychainService = @"cn.sensorsdata.SensorsAnalytics.id";


static NSString *const SensorsAnalyticsLoginId = @"cn.sensorsdata.login_id";


static NSString *const SensorsAnalyticsEventBeginKey = @"event_begin";

static NSString *const SensorsAnalyticsEventDurationKey = @"event_duration";
static NSString *const SensorsAnalyticsEventIsPauseKey = @"is_pause";

static NSUInteger const SensorsAnalyticsDefalutFlushEventCount = 50;

static SensorsAnalyticsSDK *sharedInstance = nil;

@interface SensorsAnalyticsSDK ()
@property (nonatomic,strong)NSDictionary<NSString *, id> *automaticProperties;

@property (nonatomic)BOOL applicationWillResignActive;

//是否为被启动
@property (nonatomic,getter=isLaunchedPassively) BOOL launchedPassively;



@property (nonatomic,copy)NSString *loginId;


//事件开始发生的时间戳
@property (nonatomic,strong)NSMutableDictionary<NSString *,NSDictionary *> *trackTimer;

//保存进入后台时未暂停的事件总称
@property (nonatomic,strong)NSMutableArray<NSString *> *enterBackgroundTrackTimerEvents;

//文件缓存事件对象
@property (nonatomic,strong)SensorsAnalyticsFileStore *fileStore;

//数据库存储对象
@property (nonatomic,strong)SensorsAnalyticsDatabase *database;

@property (nonatomic,strong)SensorsAnalyticsNetwork *network;

//使flush在队列里执行
@property (nonatomic,strong)dispatch_queue_t serialQueue;

//定时上传事件的计时器
@property (nonatomic,strong)NSTimer *flushTimer;

@end

@implementation SensorsAnalyticsSDK{
    NSString *_anonymousId;
}


#pragma mark - FlushTimer
-(void)startFlushTimer{
    if (self.flushTimer) {
        return;
    }
    NSTimeInterval interval = self.flushInterval < 5 ? 5 :self.flushInterval;
    self.flushTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(flush) userInfo:nil repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:self.flushTimer forMode:NSRunLoopCommonModes];
}
//停止上传数据的计时器
-(void)stopFlushTimer{
    [self.flushTimer invalidate];
    self.flushTimer = nil;
}

-(void)setFlushInterval:(NSUInteger)flushInterval{
    if (_flushInterval != flushInterval) {
        _flushInterval = flushInterval;
        //上传本地缓存的所有事件数据
        [self flush];
        //先暂停计时器
        [self stopFlushTimer];
        //重新开启计时器
        [self startFlushTimer];
    }
}

//---------------------------------设备相关--------------------------------------------------------------------------------
-(void)saveAnonymousId:(NSString *)anonymousId{
    //保存设备ID
    [[NSUserDefaults standardUserDefaults] setObject:anonymousId forKey:SensorsAnalyticsAnonymousId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SensorsAnalyticsKeychainItem *item = [[SensorsAnalyticsKeychainItem alloc] initWithService:SensorsAnalyticsKeychainService key:SensorsAnalyticsAnonymousId];
    if (anonymousId) {
        //当设备ID不为空时，将其保存在keychain中
        [item update:anonymousId];
    }else{
        //当设备ID为空时，删除keychain中的值
        [item remove];
    }
}



-(void)setAnonymousId:(NSString *)anonymousId{
    _anonymousId = anonymousId;
    //保存设备ID
    [self saveAnonymousId:anonymousId];
}
-(NSString *)anonymousId{
    if (_anonymousId) {
        return _anonymousId;
    }
    //从NSUserDefaults取出ID
    _anonymousId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyticsAnonymousId];
    if (_anonymousId) {
        return _anonymousId;
    }
    //获取IDFA
    Class cls = NSClassFromString(@"ASIdentifierManager");
    if (cls) {
#pragma clang diagnostic push
#pragma clang diagonstic ignored "-Wundeclared-selector"
        //获取ASIdentifierManager的单利对象
        id manager = [cls performSelector:@selector(shareManager)];
        SEL selector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
        BOOL (*isAdvertisingTrackingEnabled)(id ,SEL) = (BOOL (*)(id,SEL))
        [manager methodForSelector:selector];
        if (isAdvertisingTrackingEnabled(manager,selector)) {
            //使用IDFA作为设别ID
            _anonymousId = [(NSUUID *) [manager performSelector:@selector(advertisingIdentifier)] UUIDString];
        }
#pragma clang diagonstic pop
    }
    if (!_anonymousId) {
        _anonymousId = UIDevice.currentDevice.identifierForVendor.UUIDString;
    }
    if (!_anonymousId) {
        //使用UUID作为设别ID
        _anonymousId = NSUUID.UUID.UUIDString;
    }
    //保存设备ID
    [self saveAnonymousId:_anonymousId];
    return _anonymousId;
}

//-----------------------------------------------------------------------------------------------------------------

//---------------------------------登录相关--------------------------------------------------------------------------------

//-(void)login:(NSString *)loginId{
//    self.loginId = loginId;
//    //在本地保存登录ID
//    [[NSUserDefaults standardUserDefaults] setObject:loginId forKey:SensorsAnalyticsLoginId];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

//-------------------------------------登录相关----------------------------------------------------------------------------

//- (instancetype)init{
//    self = [super init];
//    if (self) {
//        _automaticProperties = [self collectAutomaticProperties];
//
//        //设置是否被启动标记
//        _launchedPassively = UIApplication.sharedApplication.backgroundTimeRemaining != UIApplicationBackgroundFetchIntervalNever;
//
//        //
//        _loginId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyticsLoginId];
//
////        _anonymousId = [self anonymousId];
//
//        //初始化时间戳
//        _trackTimer = [NSMutableDictionary dictionary];
//
//        _enterBackgroundTrackTimerEvents = [NSMutableArray array];
//
//        _fileStore = [[SensorsAnalyticsFileStore alloc]init];
//
//        _database = [[SensorsAnalyticsDatabase alloc]init];
//
//        //此处需要配置一个可用的ServerURL
//        _network = [[SensorsAnalyticsNetwork alloc] initWithServerURL:[NSURL URLWithString:@""]];
//
//        //添加应用程序状态监听
//        [self setupListeners];
//
//    }
//    return self;
//}

-(instancetype)initWithServerURL:(NSString *)urlString{
    self = [super init];
    if (self) {
        _automaticProperties = [self collectAutomaticProperties];
        
        //设置是否被启动标记
        _launchedPassively = UIApplication.sharedApplication.backgroundTimeRemaining != UIApplicationBackgroundFetchIntervalNever;
        
        //
        _loginId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyticsLoginId];
        
//        _anonymousId = [self anonymousId];
        
        //初始化时间戳
        _trackTimer = [NSMutableDictionary dictionary];
        
        _enterBackgroundTrackTimerEvents = [NSMutableArray array];
        
        _fileStore = [[SensorsAnalyticsFileStore alloc]init];
        
        _database = [[SensorsAnalyticsDatabase alloc]init];
        
        //此处需要配置一个可用的ServerURL
        _network = [[SensorsAnalyticsNetwork alloc] initWithServerURL:[NSURL URLWithString:urlString]];
        
        NSString *queueLabel = [NSString stringWithFormat:@"cn.sensorsdata.%@.%p",self.class,self];
        _serialQueue = dispatch_queue_create([queueLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        
        _flushBulkSize = 100;//超过100条上报
        _flushInterval = 15;//每隔15秒上报
        
        //添加应用程序状态监听
        [self setupListeners];
        
        [SensorsAnalyticsExceptionHandler sharedInstance];
        
        [self startFlushTimer];
    }
    return self;
}

+(void)startWithServerURL:(NSString *)urlString{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SensorsAnalyticsSDK alloc] initWithServerURL:urlString];
    });
}

+(SensorsAnalyticsSDK *)sharedInstance{
//    static dispatch_once_t onceToken;
//    static SensorsAnalyticsSDK *sdk = nil;
//    dispatch_once(& onceToken,^{
//        sdk = [[SensorsAnalyticsSDK alloc]init];
//    });
//    return sdk;
    return sharedInstance;
}

-(NSDictionary<NSString *, id>*)collectAutomaticProperties{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[@"$os"] = @"iOS";
    properties[@"$lib"] = @"iOS";
    properties[@"$manufacturer"] = @"apple";
    properties[@"$lib_version"] = SensorsAnalyticsVersion;
    properties[@"$model"] = [self deviceModel];
    properties[@"$os_version"] = UIDevice.currentDevice.systemVersion;
    properties[@"$app_version"] = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    
    return [properties copy];
}

-(NSString *)deviceModel{
    size_t size;
    sysctlbyname("hw.machine",NULL,&size,NULL,0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
    return results;
}

//- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,id> *)properties{
//    NSMutableDictionary *event = [NSMutableDictionary dictionary];
//    event[@"event"] = eventName;
//    event[@"time"] = [NSNumber numberWithLong:NSDate.date.timeIntervalSince1970 * 1000];
//
//    event[@"distinct_id"] = self.loginId ? : self.anonymousId;
//
//    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
//    [eventProperties addEntriesFromDictionary:self.automaticProperties];
//    [eventProperties addEntriesFromDictionary:properties];
//
//    //判断是否为被动启动状态
//    if (self.isLaunchedPassively) {
//        eventProperties[@"$app_state"] = @"background";
//    }
//
//    event[@"properties"] = eventProperties;
//    [self printEvent:event];
//}

//-(void)trackAppClickWithView:(UIView *)view properties:(nullable NSDictionary <NSString * , id> *)properties{
//    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
//    //获取控件类型
//    eventProperties[@"$element_type"] = view.sensorsdata_elementType;
//    //获取控件文本
//    eventProperties[@"$element_content"] = view.sensorsdata_elementContent;
//    //获取控件所在的UIViewController
//    UIViewController *vc = view.sensorsdata_viewController;
//    eventProperties[@"$screen_name"] = NSStringFromClass(vc.class);
//    //添加自定义属性
//    [eventProperties addEntriesFromDictionary:properties];
//    //触发$AppClick事件
//    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppClick" properties:eventProperties];
//}

-(void)printEvent:(NSDictionary *)event{
#if DEBUG
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:event options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return NSLog(@"JSON serialized Error:%@",error);
    }
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Event]:%@",json);
#endif
    
}

-(void)setupListeners{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}
-(void)applicationDidEnterBackground:(NSNotification *)notification{
    //还原标记位
    self.applicationWillResignActive = NO;
    //触发$AppEdn事件
//    [self track:@"$AppEnd" properties:nil];
    [self trackTimerEnd:@"$AppEnd" properties:nil];
    
    UIApplication *application = UIApplication.sharedApplication;
    //初始化标识符
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    //结束后台任务
    void (^endBackgroundTask)(void) = ^(){
        [application endBackgroundTask:backgroundTaskIdentifier];
        backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    };
    //标记长时间运行的后台任务
    backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        endBackgroundTask();
    }];
    dispatch_async(self.serialQueue, ^{
       //发送数据
        [self flushByEventCount:SensorsAnalyticsDefalutFlushEventCount background:YES];
        endBackgroundTask();
    });
    
    
    //暂停所有事件时长统计
    [self.trackTimer enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj[SensorsAnalyticsEventIsPauseKey] boolValue]) {
            [self.enterBackgroundTrackTimerEvents addObject:key];
            [self trackTimerPause:key];
        }
    }];
    //停止计时器
    [self stopFlushTimer];
}
-(void)applicationDidBecomeActive:(NSNotification *)notification{
    if (self.applicationWillResignActive) {
        self.applicationWillResignActive = NO;
        return;
    }
    //将被动启动标记为NO，正常记录事件
    self.launchedPassively = NO;
    [self track:@"$AppStart" properties:nil];
    
    //恢复所有事件时长统计
    for (NSString *event in self.enterBackgroundTrackTimerEvents) {
        [self trackTimerResume:event];
    }
    [self.enterBackgroundTrackTimerEvents removeAllObjects];
    
    //开始$AppEnd事件时计时
    [self trackTimerStart:@"$AppEnd"];
    
    //开启计时器
    [self startFlushTimer];
}
-(void)applicationDidFinishLaunching:(NSNotification *)notification{
    if (self.isLaunchedPassively) {
        [self track:@"$AppStartPassively" properties:nil];
    }
}

-(void)applicationWillResignActive:(NSNotification *)notification{
    //标记已接收到UIApplicationWillResignActiveNotification本地通知
    self.applicationWillResignActive = YES;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-(void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties{
//    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
//
//    //获取用户点击 uitableViewCell控件对象
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    //设置被用户点击的cell控件上的内容（$element_content）
//    eventProperties[@"$element_content"] = cell.sensorsdata_elementContent;
//    //设置被用户点击的cell控件所在的位置($element_position)
//    eventProperties[@"$element_position"] = [NSString stringWithFormat:@"%ld:%ld",(long)indexPath.section,(long)indexPath.row];
//    //添加自定义属性
//    [eventProperties addEntriesFromDictionary:properties];
//    //触发$AppClick
//    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:tableView properties:eventProperties];
//}

//-(void)trackAppClickWithCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties{
//    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
//    //获取用户点击 UICollectionViewCell控件对象
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    //设置被用户点击的cell控件上的内容（$element_content）
//    eventProperties[@"$element_content"] = cell.sensorsdata_elementContent;
//    //设置被用户点击的cell控件所在的位置($element_position)
//    eventProperties[@"$element_position"] = [NSString stringWithFormat:@"%ld:%ld",(long)indexPath.section,(long)indexPath.row];
//
//    //添加自定义属性
//    [eventProperties addEntriesFromDictionary:properties];
//    //触发$AppClick
//    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:collectionView properties:eventProperties];
//}


+(double)currentTime{
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

+(double)systemUpTime{
    return NSProcessInfo.processInfo.systemUptime * 1000;
}

-(void)flush{
    dispatch_async(self.serialQueue, ^{
        //默认一次向服务器发送50条数据
        [self flushByEventCount:SensorsAnalyticsDefalutFlushEventCount background:NO];
    });
}
-(void)flushByEventCount:(NSUInteger )count background:(BOOL)background{
    
    if (background) {
        __block BOOL isContinue = YES;
        dispatch_sync(dispatch_get_main_queue(), ^{
           //当运行时间大于请求超时时间时，为保证数据库删除时应用不被强杀，不再继续上传
            isContinue = UIApplication.sharedApplication.backgroundTimeRemaining >= 30;
        });
        if (!isContinue) {
            return;
        }
    }
    //获取本地数据
    NSArray<NSString *> *events = [self.database selectEventsForCount:count];
    //当本地存储的数据为0或者上传失败时，直接返回，退出递归调用
    if (events.count == 0 || ![self.network flushEvents:events]) {
        return;
    }
    //当删除数据失败时，直接返回，退出递归调用，防止死循环
    if (![self.database deleteEventsForCount:count]) {
        return;
    }
    //继续上传本地的其他数据
    [self flushByEventCount:count background:background];
}

@end



@implementation SensorsAnalyticsSDK(Track)

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,id> *)properties{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    //设置事件名称
    event[@"event"] = eventName;
    //设置事件发生的时间戳，单位为毫秒
    event[@"time"] = [NSNumber numberWithLong:NSDate.date.timeIntervalSince1970 * 1000];
    
    event[@"distinct_id"] = self.loginId ? : self.anonymousId;

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    //添加预置属性
    [eventProperties addEntriesFromDictionary:self.automaticProperties];
    //添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    
    //判断是否为被动启动状态
    if (self.isLaunchedPassively) {
        eventProperties[@"$app_state"] = @"background";
    }
    //设置事件属性
    event[@"properties"] = eventProperties;
    
    dispatch_async(self.serialQueue, ^{
        //打印事件信息
        [self printEvent:event];
    //    [self.fileStore saveEvent:event];
        [self.database insertEvent:event];
    });
    //策略一，客户端本地已经缓存的超过一定条数时同步数据
    if (self.database.eventCount >= self.flushBulkSize) {
        [self flush];
    }
}

-(void)trackAppClickWithView:(UIView *)view properties:(nullable NSDictionary <NSString * , id> *)properties{
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    //获取控件类型
    eventProperties[@"$element_type"] = view.sensorsdata_elementType;
    //获取控件文本
    eventProperties[@"$element_content"] = view.sensorsdata_elementContent;
    //获取控件所在的UIViewController
    UIViewController *vc = view.sensorsdata_viewController;
    eventProperties[@"$screen_name"] = NSStringFromClass(vc.class);
    //添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    //触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppClick" properties:eventProperties];
}
-(void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties{
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    
    //获取用户点击 uitableViewCell控件对象
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //设置被用户点击的cell控件上的内容（$element_content）
    eventProperties[@"$element_content"] = cell.sensorsdata_elementContent;
    //设置被用户点击的cell控件所在的位置($element_position)
    eventProperties[@"$element_position"] = [NSString stringWithFormat:@"%ld:%ld",(long)indexPath.section,(long)indexPath.row];
    //添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    //触发$AppClick
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:tableView properties:eventProperties];
}
-(void)trackAppClickWithCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties{
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    //获取用户点击 UICollectionViewCell控件对象
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //设置被用户点击的cell控件上的内容（$element_content）
    eventProperties[@"$element_content"] = cell.sensorsdata_elementContent;
    //设置被用户点击的cell控件所在的位置($element_position)
    eventProperties[@"$element_position"] = [NSString stringWithFormat:@"%ld:%ld",(long)indexPath.section,(long)indexPath.row];

    //添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    //触发$AppClick
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:collectionView properties:eventProperties];
}
-(void)login:(NSString *)loginId{
    self.loginId = loginId;
    //在本地保存登录ID
    [[NSUserDefaults standardUserDefaults] setObject:loginId forKey:SensorsAnalyticsLoginId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end


//---------------------------------------时间相关---------------------------------------------------------------------
#pragma mark - Timer
@implementation SensorsAnalyticsSDK(Timer)
-(void)trackTimerStart:(NSString *)event{
    //记录事件开始时间
    self.trackTimer[event] = @{SensorsAnalyticsEventBeginKey:@([SensorsAnalyticsSDK systemUpTime])};
}
-(void)trackTimerEnd:(NSString *)event properties:(nullable NSDictionary *)properties{
    NSDictionary *eventTimer = self.trackTimer[event];
    if (!eventTimer) {
        return [self track:event properties:properties];
    }
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:properties];
    //移除
    [self.trackTimer removeObjectForKey:event];
    
    if ([eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
        //获取事件时长
        double eventDuration = [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue];
        //设置事件时长属性
        p[@"$event_duration"] = @([[NSString stringWithFormat:@"%.3lf",eventDuration] floatValue]);
        
    }else{
        //事件开始时间
        double beginTime = [(NSNumber *)eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
        //获取当前时间->获取当前系统启动时间
        double currentTime = [SensorsAnalyticsSDK systemUpTime];
        //计算事件时长
        double eventDuration = currentTime - beginTime + [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue];
        //设置事件时长属性
        p[@"$event_duration"] = @([[NSString stringWithFormat:@"%.3lf",eventDuration] floatValue]);
    }
    
    //事件开始时间
//    double beginTime = [(NSNumber *)eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
//    //获取当前时间->获取当前系统启动时间
//    double currentTime = [SensorsAnalyticsSDK systemUpTime];
//    //计算事件时长，
//    double eventDuration = currentTime - beginTime;
//    //设置事件时长属性
//    [p setObject:@([[NSString stringWithFormat:@"%.3lf",eventDuration] floatValue]) forKey:@"$event_duration"];
    //触发事件
    [self track:event properties:p];
}


-(void)trackTimerPause:(NSString *)event{
    NSMutableDictionary *eventTimer = [self.trackTimer[event] mutableCopy];
    //如果没有开始，直接返回
    if (!eventTimer) {
        return;
    }
    //如果该事件时长统计已经暂停，直接返回，不做任何处理
    if ([eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
        return;
    }
    //获取当前系统启动时间
    double systemUpTime = [SensorsAnalyticsSDK systemUpTime];
    //获取开始时间
    double beginTime = [eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
    //计算暂停前统计时长
    double duration = [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue] + systemUpTime - beginTime;
    eventTimer[SensorsAnalyticsEventDurationKey] = @(duration);
    
    //事件处于暂停状态
    eventTimer[SensorsAnalyticsEventIsPauseKey] = @(YES);
    
    self.trackTimer[event] = eventTimer;
}

-(void)trackTimerResume:(NSString *)event{
    NSMutableDictionary *eventTimer = [self.trackTimer[event] mutableCopy];
    //如果没有开始，直接返回
    if (!eventTimer) {
        return;
    }
    //如果该事件时长统计没有暂停，直接返回，不做任何处理
    if (![eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
        return;
    }
    //获取当前系统启动时间
    double systemUpTime = [SensorsAnalyticsSDK systemUpTime];
    //重置事件开始时间
    eventTimer[SensorsAnalyticsEventBeginKey] = @(systemUpTime);
    //将事件暂停标记设置为NO
    eventTimer[SensorsAnalyticsEventIsPauseKey] = @(NO);
    
    self.trackTimer[event] = eventTimer;
}

@end
