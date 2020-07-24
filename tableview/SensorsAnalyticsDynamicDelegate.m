//
//  SensorsAnalyticsDynamicDelegate.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/20.
//  Copyright © 2020 Company. All rights reserved.
//

#import "SensorsAnalyticsDynamicDelegate.h"
#import "SensorsAnalyticsSDK.h"
#import <objc/runtime.h>
//delegate对象的子类前缀
static NSString *const kSensorsDelegatePrefix = @"cn.SensorsData";
//tableView:didSelectRowAtIndexPath:方法指针类型
typedef void(* SensorsDidSelectImplementation) (id,SEL,UITableView *,NSIndexPath *);

@implementation SensorsAnalyticsDynamicDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //第一步，获取原始类
    Class cla = object_getClass(tableView);
    NSString *className = [NSStringFromClass(cla) stringByReplacingOccurrencesOfString:kSensorsDelegatePrefix withString:@""];
    Class originaClass = objc_getClass([className UTF8String]);
    //第二步
    SEL originalSelector = NSSelectorFromString(@"tableView:didSelectRowAtIndexPath:");
    Method originalMethod = class_getInstanceMethod(originaClass, originalSelector);
    IMP originalImplmentation = method_getImplementation(originalMethod);
    if (originalImplmentation) {
        ((SensorsDidSelectImplementation)originalImplmentation)(tableView.delegate,originalSelector,tableView,indexPath);
    }
    //第三步
    //触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithTableView:tableView didSelectRowAtIndexPath:indexPath properties:nil];
}

+(void)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate{
    SEL originalSelector = NSSelectorFromString(@"tableView:didSelectRowAtIndexPath:");
    if (![delegate respondsToSelector:originalSelector]) {
        return;
    }
    //动态创建一个新类
    Class originalClass = object_getClass(delegate);
    NSString *originalClassName = NSStringFromClass(originalClass);
    //当delegate对象已经是一个动态创建的类时，无须重复设置，直接返回
    if ([originalClassName hasPrefix:kSensorsDelegatePrefix]) {
        return;
    }
    NSString *subClassName = [kSensorsDelegatePrefix stringByAppendingString:originalClassName];
    Class subClass = NSClassFromString(subClassName);
    if (!subClass) {
        //注册一个新类，其父类为originalClass
        subClass = objc_allocateClassPair(originalClass, subClassName.UTF8String, 0);
        //获取SensorsAnalyticsDynamicDelegate中的ableView:didSelectRowAtIndexPath:方法指针
        Method method = class_getInstanceMethod(self, originalSelector);
        //获取方法实现
        IMP methodIMP = method_getImplementation(method);
        //获取方法的类型编码
        const char *types = method_getTypeEncoding(method);
        //subClass 中添加ableView:didSelectRowAtIndexPath:方法
        if (!class_addMethod(subClass, originalSelector, methodIMP, types)) {
            NSLog(@"Cannot copy method to destination selector %@ as it already exists",NSStringFromSelector(originalSelector));
        }
        
        
        
        
        //获取SensorsAnalyticsDynamicDelegate中的sensorsdata_class方法指针
        Method classMethod = class_getInstanceMethod(self, @selector(sensorsdata_class));
        //获取方法的实现
        IMP classIMP = method_getImplementation(classMethod);
        //获取方法的类型编码
        const char *classTypes = method_getTypeEncoding(classMethod);
        //在subClass中添加class方法
        if (!class_addMethod(subClass, @selector(class), classIMP, classTypes)) {
            NSLog(@"Cannot copy method to destination selector as it already exists");
        }

        //子类和原始类的大小必须相同，不能有更多的成员变量（ivars）或属性
        //如果不同，将导致设置新的子类时，内存被重新设置，充血对象的isa指针
        if (class_getInstanceSize(originalClass) != class_getInstanceSize(subClass)) {
            NSLog(@"Cannot create subclass of Delegate,because the created subclass is not the same size. %@",NSStringFromClass(originalClass));
            NSAssert(NO, @"Classes must be the same size to swizzle isa .");
            return;
        }
        
        
        
        
        //将delegate对象设置成新创建的子类对象
        objc_registerClassPair(subClass);
    }
    if (object_setClass(delegate, subClass)) {
        NSLog(@"Successfully created delegate proxy automatically .");
    }
}

-(Class)sensorsdata_class{
    //获取对象类
    Class class = object_getClass(self);
    //将类名前缀替换成空字符串，获取原始类名
    NSString *className = [NSStringFromClass(class) stringByReplacingOccurrencesOfString:kSensorsDelegatePrefix withString:@""];
    //通过字符串获取，并返回
    return objc_getClass([className UTF8String]);
}
@end
