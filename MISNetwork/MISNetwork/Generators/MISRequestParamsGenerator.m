//
//  MISRequestParamsGenerator.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISRequestParamsGenerator.h"
#import "MISAppContext.h"

@implementation MISRequestParamsGenerator

#pragma mark - 类方法

+ (NSDictionary*)commonParams
{
    MISAppContext* context = [MISAppContext sharedInstance];
    return @{
        @"app_name" : context.appName ?: @"",
        @"machine_model_name" : context.machineModelName ?: @"",
        @"system_version" : context.systemName ?: @"",
        @"app_version" : context.appVersion ?: @"",
        @"app_build_version" : context.appBuildVersion ?: @""
    };
}

+ (NSDictionary*)getCustomCommonParams
{
    if (!customCommonParams) {
        customCommonParams = @{};
    }
    return customCommonParams;
}

+ (void)setCustomCommonParams:(NSDictionary*)params
{
    customCommonParams = params;
}

@end
