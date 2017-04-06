//
//  WSCacheArgument.m
//  WSDataBank
//
//  Created by guojianfeng on 17/3/7.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSCacheArgument.h"

@interface WSCacheArgument()
@property (nonatomic, strong, readwrite) NSString *key;
@end
@implementation WSCacheArgument
- (id)initWithKey:(NSString *)key;{
    if (self = [super init]) {
        self.key = key;
        self.cacheOptions = WSCacheArgumentIgnoreCache;
        _cacheTimeInSeconds = 0;
        _offlineTimeInSeconds = 7200;
    }
    return self;
}


#pragma mark WSCacheArgumentProtocol
- (void)cacheResponseWithCacheOptions:(WSCacheArgumentOptions)cacheOptions
                   cacheTimeInSeconds:(NSInteger)cacheTimeInSeconds
                 offlineTimeInSeconds:(NSInteger)offlineTimeInSeconds{
    self.cacheOptions = cacheOptions;
    self.cacheTimeInSeconds = cacheTimeInSeconds;
    self.offlineTimeInSeconds = offlineTimeInSeconds;
}

@end
