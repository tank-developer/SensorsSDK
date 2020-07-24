//
//  SensorsAnalyticsSDK.h
//  SensorsSDK
//
//  Created by wujun on 2020/6/19.
//  Copyright © 2020 Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface SensorsAnalyticsSDK : NSObject
+(SensorsAnalyticsSDK *)sharedInstance;
/*
 想服务器同步本地所有数据
 */
-(void)flush;

//禁止使用init方法
-(instancetype)init NS_UNAVAILABLE;

/*
 初始化SDK
 @param urlString 接受数据的服务器URL
 */
+(void)startWithServerURL:(NSString *)urlString;

//当本地缓存的事件达到最大条数时，上传数据（默认为100条）
@property (nonatomic)NSUInteger flushBulkSize;

//两次数据发送的时间间隔，单位为妙
@property (nonatomic)NSUInteger flushInterval;

@end


//SensorsAnalyticsSDK类别
#pragma mark - Track
@interface SensorsAnalyticsSDK (Track)

-(void)track:(NSString *)eventName properties:(nullable NSDictionary<NSString *, id> *)properties;


/*
 触发$AppClick事件
 @param view 触发事件的控件
 @param properties 自定义事件属性
 */
-(void)trackAppClickWithView:(UIView *)view properties:(nullable NSDictionary <NSString * , id> *)properties;


/*
    支持  UITableView触发$AppClick事件
    @param tableView触发事件的UITableView视图
    @param indexPath在UITableView中点击的位置
    @param properties自定义事件属性
 */
-(void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties;

/*
   支持  UICollectionView触发$AppClick事件
   @param collectionView触发事件的UICollectionView视图
   @param indexPath在UICollectionView中点击的位置
   @param properties自定义事件属性
*/
-(void)trackAppClickWithCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *,id> *)properties;


//设备ID，匿名ID
@property (nonatomic,copy)NSString *anonymousId;

/*
 用户登录，设置登录ID
 @param loginId 用户登录的ID
 */
-(void)login:(NSString *)loginId;


@end

#pragma mark - Timer
@interface SensorsAnalyticsSDK (Timer)

/*
 开始统计时常
 调用这个接口，并不会真正触发一次事件，只是开始计时
 @param evevt 事件名
 */
-(void)trackTimerStart:(NSString *)event;
/*
 结束事件时长统计，计算时长
 事件发生时长是从调用trackTimerStart方法开始，一直调用-trackTimerEnd：properties:结束。
 如果多次调用-trackTimerStart:方法，则从最后一次调用开始计算
 如果没有调用-trackTimerStart:方法，就直接用-trackTimerEnd：properties:方法，则触发一次普通事件，不带时长属性。
 @param event 事件名，与开始时事件名一一对应
 @param properties 事件属性
 */
-(void)trackTimerEnd:(NSString *)event properties:(nullable NSDictionary *)properties;


/*
 暂停统计事件时长
 如果该事件，即没有调用-trackTimerStart:方法，则不做任何操作
 @param event 事件名
 */
-(void)trackTimerPause:(NSString *)event;

/*
 恢复统计事件时长
 如果该事件并未暂停，即没有调用-trackTimerPause:方法，则没有影响
 @param event 事件名
 */
-(void)trackTimerResume:(NSString *)event;

@end

NS_ASSUME_NONNULL_END
