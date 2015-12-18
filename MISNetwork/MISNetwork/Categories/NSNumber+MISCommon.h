//
//  NSNumber+MISCommon.h
//  MISNetwork
//
//  Created by CM on 15/12/17.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (MISCommon)

/**
 Creates and returns an NSNumber object from a string.
 Valid format: @"12", @"12.345", @" -0xFF", @" .23e99 "...
 
 @param string  The string described an number.
 
 @return an NSNumber when parse succeed, or nil if an error occurs.
 */
+ (NSNumber*)numberWithString:(NSString*)string;

@end
