//
//  MISAppContext.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISAppContext.h"
#import "AFNetworkReachabilityManager.h"
#include <sys/sysctl.h>
#import <UIKit/UIKit.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface MISAppContext ()

#pragma mark - 属性

/**
 *  应用的名称
 */
@property (nonatomic, copy, readwrite) NSString *appName;

/**
 *  设备的型号,比如“iPhone6，1 ipho4，6”
 */
@property (nonatomic, copy, readwrite) NSString *machineModel;

/**
 *  设备的型号名称，比如“iPhone5s”
 */
@property (nonatomic, copy, readwrite) NSString *machineModelName;

/**
 *  系统的版本号
 */
@property (nonatomic, copy, readwrite) NSString *systemVersion;

/**
 *  系统的名称
 */
@property (nonatomic, copy, readwrite) NSString *systemName;

/**
 *  应用的 Bundle Name
 */
@property (nonatomic, copy, readwrite) NSString *appBundleName;

/**
 *  应用的 bundleID
 */
@property (nonatomic, copy, readwrite) NSString *appBundleID;

/**
 *  应用的版本号，例如“1.1.1”
 */
@property (nonatomic, copy, readwrite) NSString *appVersion;

/**
 *  应用的build版本号，例如“121”
 */
@property (nonatomic, copy, readwrite) NSString *appBuildVersion;

/**
 *  WIFI的IP地址，例如“192.168.1.111”
 */
@property (nonatomic, copy, readwrite) NSString *ipAddressOfWIFI;

/**
 *  手机的IP地址，例如“10.2.2.222”
 */
@property (nonatomic, copy, readwrite) NSString *ipAddressOfCell;

/**
 *  网络是否可用
 */
@property (nonatomic, assign, readwrite, getter=isReachable) BOOL reachable;

@end

@implementation MISAppContext

#pragma mark - 初始化，单例

+ (instancetype) sharedInstance
{
    static MISAppContext *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!instance){
            instance = [[MISAppContext alloc] init];
        }
    });
    return instance;
}

#pragma mark - Getter

- (NSString*)appName
{
    if(!_appName){
        _appName = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
    }
    return _appName;
}

- (NSString*)machineModel
{
    if(!_machineModel){
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        _machineModel = [NSString stringWithUTF8String:machine];
        free(machine);
    }
    return _machineModel;
    
}

- (NSString*)machineModelName
{
    if(!_machineModelName){
        NSString *model = self.machineModel;
        if(!model){
            return nil;
        }
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch",
                              @"Watch1,2" : @"Apple Watch",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        _machineModelName = dic[model];
        if (!_machineModelName) _machineModelName = model;
    }
    return _machineModelName;
}

- (NSString*)systemVersion
{
    if(!_systemVersion){
        _systemVersion = [UIDevice currentDevice].systemVersion;
    }
    return _systemVersion;
}

- (NSString*)systemName
{
    if(!_systemName){
        _systemName = [UIDevice currentDevice].systemName;
    }
    return _systemName;
}

- (NSString*)appBundleName
{
    if(!_appBundleName){
        _appBundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return _appBundleName;
}

- (NSString*)appBundleID
{
    if(!_appBundleID){
        _appBundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    }
    return _appBundleID;
}

- (NSString*)appVersion
{
    if(!_appVersion){
        _appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    return _appVersion;
}

- (NSString*)appBuildVersion
{
    if(!_appBuildVersion){
        _appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    return _appBuildVersion;
}

- (NSString*)ipAddressOfWIFI
{
    if(!_ipAddressOfWIFI){
        struct ifaddrs *addrs = NULL;
        if (getifaddrs(&addrs) == 0) {
            struct ifaddrs *addr = addrs;
            while (addr != NULL) {
                if (addr->ifa_addr->sa_family == AF_INET) {
                    if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) {
                        _ipAddressOfWIFI = [NSString stringWithUTF8String:
                                   inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                        break;
                    }
                }
                addr = addr->ifa_next;
            }
        }
        freeifaddrs(addrs);
    }
    return _ipAddressOfWIFI;
}

- (NSString*)ipAddressOfCell
{
    if(!_ipAddressOfCell){
        struct ifaddrs *addrs = NULL;
        if (getifaddrs(&addrs) == 0) {
            struct ifaddrs *addr = addrs;
            while (addr != NULL) {
                if (addr->ifa_addr->sa_family == AF_INET) {
                    if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                        _ipAddressOfCell = [NSString stringWithUTF8String:
                                   inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                        break;
                    }
                }
                addr = addr->ifa_next;
            }
        }
        freeifaddrs(addrs);
    }
    return _ipAddressOfCell;
}

- (BOOL) isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    }
    else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

@end
