//
//  WSCacheArgument.h
//  WSDataBank
//
//  Created by guojianfeng on 17/3/7.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSUInteger, WSCacheArgumentOptions) {
    WSCacheArgumentIgnoreCache                  = 0,
    /**
     *  限制频繁数据请求:当使用该类型时cacheTimeInSeconds不能为0，当在使用请求的时候会比对上次成功缓存的数据文件时间，
     *  如果小于cacheTimeInSeconds则不再请求，直接返回上次成功返回的数据，当数据过期则会删除
     */
    WSCacheArgumentRestrictedFrequentRequests   = 1 << 0,
    /**
     *  当请求发生错误的时候，如果缓存存在则返回上次成功请求返回的数据,
     *  该类型的优先级高于NLCacheArgumentRestrictedFrequentRequests,当使用该功能的时候缓存的数据在相同环境中是永久的。
     *  该设置只在之前曾经请求成功并该次请求失败时才会有数据返回
     */
    WSCacheArgumentResponseAtErrorRequest       = 1 << 1,
};

@protocol NLCacheArgumentProtocol <NSObject>
- (void)cacheResponseWithCacheOptions:(WSCacheArgumentOptions)cacheOptions
                   cacheTimeInSeconds:(NSInteger)cacheTimeInSeconds
                 offlineTimeInSeconds:(NSInteger)offlineTimeInSeconds;
@end

@interface WSCacheArgument : NSObject
@property (nonatomic, strong, readonly) NSString *key;
/** 缓存类型配置 默认：NLCacheArgumentIgnoreCache*/
@property (nonatomic, assign) WSCacheArgumentOptions cacheOptions;
/** 缓存有效期 单位:秒 默认:0秒*/
@property (nonatomic, assign) NSInteger cacheTimeInSeconds;
/** 离线缓存的有效期 单位:秒,默认:7200秒*/
@property (nonatomic, assign) NSInteger offlineTimeInSeconds;
- (id)initWithKey:(NSString *)key;
@end
