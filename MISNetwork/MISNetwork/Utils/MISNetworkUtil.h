//
//  MISNetworkUtil.h
//  MISNetwork
//
//  Created by CM on 15/12/4.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISNetworkUtil : NSObject

+ (NSString*) paramsStringFromParams:(NSDictionary*)params urlEncoded:(BOOL)urlEncoded;

+ (NSString*) paramsStringFromArray:(NSArray*)params;

+ (NSArray*) sortedArrayFromParams:(NSDictionary*)params urlEncoded:(BOOL)urlEncoded;

@end
