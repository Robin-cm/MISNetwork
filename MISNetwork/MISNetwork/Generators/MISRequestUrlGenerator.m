//  请求路径的生成
//  MISRequestUrlGenerator.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISRequestUrlGenerator.h"
#import "MISNetworkUtil.h"

@implementation MISRequestUrlGenerator

#pragma mark - 类方法


+ (NSString*) urlStringWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName
{
    if(!baseUrl || !baseUrl.length || !methodName || !methodName.length){
        NSLog(@"请求地址不能为空");
        return nil;
    }
    
    NSString* baseUrlLastChar = [baseUrl substringFromIndex:(baseUrl.length - 1)];
    if([baseUrlLastChar isEqualToString:@"/"]){
        baseUrl = [baseUrl substringToIndex:(baseUrl.length - 1)];
    }
    
    NSString *methodNameFirstChar = [methodName substringToIndex:1];
    if([methodNameFirstChar isEqualToString:@"/"]){
        methodName = [methodName substringFromIndex:1];
    }
    
    return [NSString stringWithFormat:@"%@/%@", baseUrl, methodName];
}


+ (NSString*) urlStringWithBaseUrl:(NSString *)baseUrl methodName:(NSString *)methodName params:(NSDictionary*)params
{
    NSString *urlNoParams = [self urlStringWithBaseUrl:baseUrl methodName:methodName];
    NSString *paramsString = [MISNetworkUtil paramsStringFromParams:params urlEncoded:YES];
    return [NSString stringWithFormat:@"%@?%@", urlNoParams, paramsString];
}

@end
