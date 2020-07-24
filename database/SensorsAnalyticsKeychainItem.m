//
//  SensorsAnalyticsKeychainItem.m
//  SensorsSDK
//
//  Created by wujun on 2020/6/21.
//  Copyright © 2020 Company. All rights reserved.
//

#import "SensorsAnalyticsKeychainItem.h"
#import <Security/Security.h>

@interface SensorsAnalyticsKeychainItem ()

@property (nonatomic,strong)NSString *service;
@property (nonatomic,strong)NSString *accessGroud;
@property (nonatomic,strong)NSString *key;

@end

@implementation SensorsAnalyticsKeychainItem

-(instancetype)initWithService:(NSString *)service key:(NSString *)key{
    return [self initWithService:service accessGroup:nil key:key];
}
-(instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup key:(NSString *)key{
    self = [super init];
    if (self) {
        _service = service;
        _key = key;
        _accessGroud = accessGroup;
    }
    return self;
}

-(nullable NSString *)value{
    NSMutableDictionary *query = [SensorsAnalyticsKeychainItem keychainQueryWithService:self.service accessGroud:self.accessGroud key:self.key];
    query[(NSString *)kSecMatchLimit] = (id)kSecMatchLimitOne;
    query[(NSString *)kSecReturnAttributes] = (id)kCFBooleanTrue;
    query[(NSString *)kSecReturnData] = (id)kCFBooleanTrue;
    CFTypeRef queryResult;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &queryResult);
    if (status == errSecItemNotFound) {
        return nil;
    }
    if (status != noErr) {
        NSLog(@"Get item value error %d",(int)status);
        return nil;
    }
//    NSData *data = [(__bridge_transfer NSDictionary)queryResult objectForKey:(NSString *)kSecValueData];
    NSData *data = [(__bridge_transfer NSDictionary *)queryResult objectForKey:(NSString *)kSecValueData];
    if (!data) {
        return nil;
    }
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Get item value %@",value);
    
    return value;
}
-(void)update:(NSString *)value{
    NSData *encodeValue = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *query = [SensorsAnalyticsKeychainItem keychainQueryWithService:self.service accessGroud:self.accessGroud key:self.key];
    NSString *originalValue = [self value];
    if (originalValue) {
        NSMutableDictionary *attributesToUpDate = [[NSMutableDictionary alloc] init];
        attributesToUpDate[(NSString *)kSecValueData] = encodeValue;
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpDate);
        if (status == noErr) {
            NSLog(@"update item ok");
        }else{
            NSLog(@"update item error %d",(int)status);
        }
    }else{
        [query setObject:encodeValue forKey:(id)kSecValueData];
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        if (status == noErr) {
            NSLog(@"add item ok");
        }else{
            NSLog(@"add item error %d",(int)status);
        }
    }
}
-(void)remove{
    NSMutableDictionary *query = [SensorsAnalyticsKeychainItem keychainQueryWithService:self.service accessGroud:self.accessGroud key:self.key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != noErr && status != errSecItemNotFound) {
        NSLog(@"remove item %d",(int)status);
    }
    
}


#pragma mark - private
+(NSMutableDictionary *)keychainQueryWithService:(NSString *)service accessGroud:(nullable NSString *)accessGroud key:(NSString *)key{
    NSMutableDictionary *query = [[NSMutableDictionary alloc]init];
    query[(NSString *)kSecClass] = (NSString *)kSecClassGenericPassword;
    query[(NSString *)kSecAttrService] = service;
    query[(NSString *)kSecAttrAccount] = key;
    query[(NSString *)kSecAttrAccessGroup] = accessGroud;
    return query;
}
@end
