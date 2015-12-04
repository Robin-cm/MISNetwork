//
//  MISRequestParamsGenerator.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  自定义的公共参数
 */
static NSDictionary *customCommonParams;

@interface MISRequestParamsGenerator : NSObject

#pragma mark - 类方法

/**
 *  得到公共的参数字典
 *
 *  @return 参数字典
 */
+ (NSDictionary*) commonParams;


/**
 *  得到自定义的公共参数
 *
 *  @return 参数字典
 */
+ (NSDictionary*) getCustomCommonParams;


/**
 *  设置自定义的公共参数
 *
 *  @param params 公共参数
 */
+ (void) setCustomCommonParams:(NSDictionary*)params;

@end
