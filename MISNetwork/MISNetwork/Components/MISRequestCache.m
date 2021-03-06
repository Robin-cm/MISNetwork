//  请求简单缓存
//  MISRequestCache.m
//  MISNetwork
//
//  Created by CM on 15/12/4.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISRequestCache.h"
#import "MISNetworkConfig.h"
#import "MISNetworkUtil.h"
#import "MISCache.h"

@interface MISRequestCache ()

//@property (nonatomic, strong) NSCache* cache;

/**
 *  缓存类
 */
@property (nonatomic, strong) MISCache* misCache;

@end

@implementation MISRequestCache

#pragma mark - Getter

//- (NSCache*)cache
//{
//    if (!_cache) {
//        _cache = [[NSCache alloc] init];
//        //只缓存1000条
//        _cache.countLimit = kMISCacheCountLimit;
//    }
//    return _cache;
//}

- (MISCache*)misCache
{
    if (!_misCache) {
        _misCache = [[MISCache alloc] initWithName:@"MISNetwork"];
        _misCache.memoryCache.ageLimit = 5;
        _misCache.diskCache.ageLimit = 5;
    }
    return _misCache;
}

#pragma mark - 类方法

+ (instancetype)sharedInstance
{
    static MISRequestCache* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[MISRequestCache alloc] init];
        }
    });
    return instance;
}

#pragma mark - 类公共方法

- (NSString*)cacheKeyWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, methodName, [MISNetworkUtil paramsStringFromParams:params urlEncoded:NO]];
}

- (NSData*)cachedDataWithKey:(NSString*)key
{
    //    MISRequestCacheObject* cachedObject = (MISRequestCacheObject*)[self.misCache objectForKey:key];
    //    //    = [self.cache objectForKey:key];
    //    if (cachedObject.isOutdated || cachedObject.isEmpty) {
    //        return nil;
    //    }
    //    else {
    //        return cachedObject.content;
    //    }
    return (NSData*)[self.misCache objectForKey:key];
}

- (NSData*)cachedDataWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    return [self cachedDataWithKey:[self cacheKeyWithBaseUrl:baseUrl methodName:methodName params:params]];
}

- (void)cacheDataWithData:(NSData*)data key:(NSString*)key
{
    //    MISRequestCacheObject* cachedObject = (MISRequestCacheObject*)[self.misCache objectForKey:key];
    //    //    MISRequestCacheObject* cachedObject = [self.cache objectForKey:key];
    //    if (!cachedObject) {
    //        cachedObject = [[MISRequestCacheObject alloc] init];
    //    }
    //    [cachedObject updateContent:data];
    [self.misCache setObject:data forKey:key];
    //    [self.cache setObject:cachedObject forKey:key];
}

- (void)cacheDataWithData:(NSData*)data baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    [self cacheDataWithData:data key:[self cacheKeyWithBaseUrl:baseUrl methodName:methodName params:params]];
}

- (void)deleteCachedDataWithKey:(NSString*)key
{
    //    [self.cache removeObjectForKey:key];
    [self.misCache removeObjectForKey:key];
}

- (void)deleteCachedDataWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    [self deleteCachedDataWithKey:[self cacheKeyWithBaseUrl:baseUrl methodName:methodName params:params]];
}

- (void)clean
{
    //    [self.cache removeAllObjects];
    [self.misCache removeAllObjects];
}

@end

//@interface MISRequestCacheObject ()
//
//@property (nonatomic, copy, readwrite) NSData* content;
//
//@property (nonatomic, copy, readwrite) NSDate* lastUpdateTime;
//
//@end
//
//@implementation MISRequestCacheObject
//
//#pragma mark - Getter
//
//- (BOOL)isEmpty
//{
//    return self.content == nil;
//}
//
//- (BOOL)isOutdated
//{
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
//    return timeInterval > kMISCacheOutdateTimeSeconds;
//}
//
//#pragma mark - Setter
//
//- (void)setContent:(NSData*)content
//{
//    _content = [content copy];
//    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
//}
//
//#pragma mark - 生命周期
//
//- (instancetype)initWithContent:(NSData*)content
//{
//    self = [super init];
//    if (self) {
//        self.content = content;
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder*)coder
//{
//    [coder encodeObject:self.content forKey:@"content"];
//}
//
//- (id)initWithCoder:(NSCoder*)decoder
//{
//    if (self = [super init]) {
//        if (decoder == nil) {
//            return self;
//        }
//        self.content = [decoder decodeObjectForKey:@"content"];
//    }
//    return self;
//}
//
//#pragma mark - 公共方法
//
//- (void)updateContent:(NSData*)content
//{
//    self.content = content;
//}

//@end
