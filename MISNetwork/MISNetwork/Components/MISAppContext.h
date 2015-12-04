//
//  MISAppContext.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISAppContext : NSObject


#pragma mark - 属性

/**
 *  应用的名称
 */
@property (nonatomic, copy, readonly) NSString *appName;

/**
 *  设备的型号,比如“iPhone6，1 ipho4，6”
 */
@property (nonatomic, copy, readonly) NSString *machineModel;

/**
 *  设备的型号名称，比如“iPhone5s”
 */
@property (nonatomic, copy, readonly) NSString *machineModelName;

/**
 *  系统的版本号
 */
@property (nonatomic, copy, readonly) NSString *systemVersion;

/**
 *  系统的名称
 */
@property (nonatomic, copy, readonly) NSString *systemName;

/**
 *  应用的 Bundle Name
 */
@property (nonatomic, copy, readonly) NSString *appBundleName;

/**
 *  应用的 bundleID
 */
@property (nonatomic, copy, readonly) NSString *appBundleID;

/**
 *  应用的版本号，例如“1.1.1”
 */
@property (nonatomic, copy, readonly) NSString *appVersion;

/**
 *  应用的build版本号，例如“121”
 */
@property (nonatomic, copy, readonly) NSString *appBuildVersion;

/**
 *  WIFI的IP地址，例如“192.168.1.111”
 */
@property (nonatomic, copy, readonly) NSString *ipAddressOfWIFI;

/**
 *  手机的IP地址，例如“10.2.2.222”
 */
@property (nonatomic, copy, readonly) NSString *ipAddressOfCell;

/**
 *  网络是否可用
 */
@property (nonatomic, assign, readonly, getter=isReachable) BOOL reachable;

#pragma mark - 初始化，单例

/**
 *  得到实例
 *
 *  @return 实例对象
 */
+ (instancetype) sharedInstance;

@end
