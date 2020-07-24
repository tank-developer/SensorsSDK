//
//  SensorsAnalyticsDelegateProxy.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import "SensorsAnalyticsDelegateProxy.h"
#import "SensorsAnalyticsSDK.h"

@interface SensorsAnalyticsDelegateProxy ()
@property (nonatomic,weak) id delegate;
@end

@implementation SensorsAnalyticsDelegateProxy
+(instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate{
    SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy alloc];
    proxy.delegate = delegate;
    return proxy;
}



-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    //返回delegate对象中对应的方法签名
    return [(NSObject *)self.delegate methodSignatureForSelector:sel];
}
-(void)forwardInvocation:(NSInvocation *)invocation{
    //先执行delegate对象的方法
    [invocation invokeWithTarget:self.delegate];
    //判断是否是cell的点击事件的代理方法
    if (invocation.selector == @selector(tableView:didSelectRowAtIndexPath:)) {
        //将方法修改为改进进行数据采集的方法，即本类中的实例方法：sensorsdata_tableView:didSelectRowAtIndexPath:
        invocation.selector = NSSelectorFromString(@"sensorsdata_tableView:didSelectRowAtIndexPath:");
        [invocation invokeWithTarget:self];
    }else if(invocation.selector == @selector(collectionView:didSelectItemAtIndexPath:)){
        invocation.selector = NSSelectorFromString(@"sensorsdata_collectionView:didSelectItemAtIndexPath:");
        [invocation invokeWithTarget:self];
    }
}
-(void)sensorsdata_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithCollectionView:collectionView didSelectItemAtIndexPath:indexPath properties:nil];
}
-(void)sensorsdata_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithTableView:tableView didSelectRowAtIndexPath:indexPath properties:nil];
}

+(instancetype)proxyWithCollectionViewDelegate:(id<UICollectionViewDelegate>)delegate{
    SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy alloc];
    proxy.delegate = delegate;
    return proxy;
}

@end
