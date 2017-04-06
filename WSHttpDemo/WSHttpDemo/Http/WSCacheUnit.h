//
//  WSCacheUnit.h
//  WSDataBank
//
//  Created by guojianfeng on 17/3/7.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCacheUnit : NSObject
+ (instancetype)sharedSingleton;

//返回是否当前缓存需要更新
- (BOOL)isCacheVersionExpiredForKey:(NSString *)key toCacheTimeInSeconds:(int)seconds;

//读取
- (NSData*)readDataForKey:(NSString*)key;
- (id)readModelForKey:(NSString*)key;
- (id)readModelFromPath:(NSString *)path;
//写
- (BOOL)writeData:(NSData*)data forKey:(NSString*)key;
- (BOOL)writeModel:(id)model forKey:(NSString *)key;
- (BOOL)writeModel:(id)model toPath:(NSString *)path;
@end
