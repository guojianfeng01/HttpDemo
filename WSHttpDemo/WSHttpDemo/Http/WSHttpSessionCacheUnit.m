//
//  WSHttpSessionCacheUnit.m
//  WSDataBank
//
//  Created by guojianfeng on 17/3/21.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSHttpSessionCacheUnit.h"
#import "WSCacheUnit.h"
#import "NSString+NLAddition.h"

@implementation WSHttpSessionCacheUnit
- (NSURLSessionDataTask *)request:(NSURLRequest *)request completeBlock:(OperationCompleteBlock)completeBlock{
   return  [self request:request uploadProgress:nil downloadProgress:nil completeBlock:completeBlock];
}

- (NSURLSessionDataTask *)request:(NSURLRequest *)request uploadProgress:(void (^)(NSProgress *))uploadProgressBlock downloadProgress:(void (^)(NSProgress *))downloadProgressBlock completeBlock:(OperationCompleteBlock)completeBlock{
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self request:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
        [self operationSuccessWithNSURLSessionTask:sessionTask responseObject:responseObject operationCompleteBlock:completeBlock cacheArgument:nil];
    } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
        [self operationFailureWithNSURLSessionTask:sessionTask
                                             error:error
                            operationCompleteBlock:completeBlock
                                     cacheArgument:nil];
    }];
    return dataTask;
}
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                      jsonParameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    
    NSString *cacheKey = [self cacheKeyWithBaseUrl:[[self baseURL] absoluteString] requestUrl:URLString httpMethod:HttpMethodPost argument:parameters];
    __block WSCacheArgument *cacheArgument = [[WSCacheArgument alloc] initWithKey:cacheKey];
    
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self requestURL:URLString jsonParameters:parameters successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
        [self operationSuccessWithNSURLSessionTask:sessionTask
                                    responseObject:responseObject
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
        [self operationFailureWithNSURLSessionTask:sessionTask
                                             error:error
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<WSMultipartFormArgument *> *)formModels
                            progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       completeBlock:(OperationCompleteBlock)completeBlock{
    NSString *cacheKey = [self cacheKeyWithBaseUrl:[[self baseURL] absoluteString] requestUrl:URLString httpMethod:HttpMethodPost argument:parameters];
    __block WSCacheArgument *cacheArgument = [[WSCacheArgument alloc] initWithKey:cacheKey];
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self requestURL:URLString parameters:parameters multipartFormConfigs:formModels progress:uploadProgress successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
        [self operationSuccessWithNSURLSessionTask:sessionTask
                                    responseObject:responseObject
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
        [self operationFailureWithNSURLSessionTask:sessionTask
                                             error:error
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    }];
    return dataTask;
}

#pragma mark - 数据请求
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    
    return [self requestURL:URLString inQueue:nil HttpMethod:method parameters:parameters completeBlock:completeBlock];
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    return [self requestURL:URLString inQueue:queue inGroup:nil HttpMethod:method parameters:parameters completeBlock:completeBlock];
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    return [self requestURL:URLString inQueue:queue inGroup:group HttpMethod:method parameters:parameters cacheBodyWithBlock:NULL completeBlock:completeBlock];
}
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                  cacheBodyWithBlock:(void (^)(id<NLCacheArgumentProtocol> cacheArgumentProtocol))cacheBlock
                       completeBlock:(OperationCompleteBlock)completeBlock{
    
    NSURLSessionDataTask *dataTask = nil;
    NSString *cacheKey = [self cacheKeyWithBaseUrl:[[self baseURL] absoluteString] requestUrl:URLString httpMethod:method argument:parameters];
    __block WSCacheArgument *cacheArgument = [[WSCacheArgument alloc] initWithKey:cacheKey];
    if (cacheBlock) {
        cacheBlock(cacheArgument);
    }
    //是否设置限制频繁数据请求
    if (cacheArgument.cacheOptions & WSCacheArgumentRestrictedFrequentRequests) {
        BOOL isCacheExpired = [[WSCacheUnit sharedSingleton] isCacheVersionExpiredForKey:cacheKey toCacheTimeInSeconds:(int)cacheArgument.cacheTimeInSeconds];
        if (!isCacheExpired) {
            id cacheObject = [self cacheObjectWithKey:cacheArgument.key];
            if (cacheObject) {
                if (completeBlock) {
                    WSResultUnit *result = [self resultUnitOperationCallbackWithResponseObject:cacheObject];
                    NSAssert(result != nil, @"result must not be nil!");
                    [result setDataFromCache:YES];
                    completeBlock(dataTask, result);
                    return dataTask;
                }
            }
        }
    }
    
    dataTask = [self requestURL:URLString inQueue:queue inGroup:group HttpMethod:method parameters:parameters
           successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
               
               [self operationSuccessWithNSURLSessionTask:sessionTask
                                           responseObject:responseObject
                                   operationCompleteBlock:completeBlock
                                            cacheArgument:cacheArgument];
           } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
               
               [self operationFailureWithNSURLSessionTask:sessionTask
                                                    error:error
                                   operationCompleteBlock:completeBlock
                                            cacheArgument:cacheArgument];
           }];
    return dataTask;
}



#pragma mark - overide
- (WSResultUnit *)resultUnitOperationCallbackWithResponseObject:(id)responseObject{
    return nil;
}
- (NSArray *)parametersToBeFiltered{
    return nil;
}

#pragma mark - cache methods
- (id)cacheObjectWithKey:(NSString *)key{
    NSData *data = [[WSCacheUnit sharedSingleton] readDataForKey:key];
    id cacheObject = nil;
    if (data) {
        cacheObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return cacheObject;
}

- (NSString *)cacheKeyWithBaseUrl:(NSString *)baseUrl
                       requestUrl:(NSString *)requestUrl
                       httpMethod:(HttpMethod)method
                         argument:(NSDictionary *)argument{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:argument];
    NSArray *keys = [self parametersToBeFiltered];
    if (keys && keys.count) {
        [dic removeObjectsForKeys:keys];
    }
    
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@",
                             (long)method, baseUrl, requestUrl,
                             [dic description], [NSString bundleShortVersionString]];
    NSString *cacheKey = [requestInfo MD5Hash];
    return cacheKey;
}

- (void)cacheJsonResponseJson:(id)jsonResponse byKey:(NSString *)key{
    if (jsonResponse != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:jsonResponse];
        [[WSCacheUnit sharedSingleton] writeData:data forKey:key];
    }
}
- (void)saveResponseToCacheFile:(id)responseObject withCacheArgument:(WSCacheArgument *)cacheArgument{
    if (!cacheArgument) {
        return;
    }
    if ((cacheArgument.cacheOptions & WSCacheArgumentResponseAtErrorRequest) || ((cacheArgument.cacheOptions & WSCacheArgumentRestrictedFrequentRequests) && [cacheArgument cacheTimeInSeconds] > 0)) {
        [self cacheJsonResponseJson:responseObject byKey:cacheArgument.key];
    }
}

#pragma mark - complete callback methods
- (void)operationSuccessWithNSURLSessionTask:(NSURLSessionTask *)dataTask
                              responseObject:(id)responseObject
                      operationCompleteBlock:(OperationCompleteBlock)completeBlock
                               cacheArgument:(WSCacheArgument *)cacheArgument{
    WSResultUnit *result = [self resultUnitOperationCallbackWithResponseObject:responseObject];
    NSAssert(result != nil, @"result must not be nil!");
    if (completeBlock) {
        completeBlock(dataTask, result);
    }
    if (result.ableCache && cacheArgument) {
        [self saveResponseToCacheFile:responseObject withCacheArgument:cacheArgument];
    }
}

- (void)operationFailureWithNSURLSessionTask:(NSURLSessionTask *)dataTask
                                       error:(NSError *)error
                      operationCompleteBlock:(OperationCompleteBlock)completeBlock
                               cacheArgument:(WSCacheArgument *)cacheArgument{
    WSResultUnit *result = nil;
    if (cacheArgument && (cacheArgument.cacheOptions & WSCacheArgumentResponseAtErrorRequest)){
        id cacheObject = [self cacheObjectWithKey:cacheArgument.key];
        BOOL isCacheExpired = [[WSCacheUnit sharedSingleton] isCacheVersionExpiredForKey:cacheArgument.key
                                                                    toCacheTimeInSeconds:(int)cacheArgument.offlineTimeInSeconds];
        if (cacheObject && !isCacheExpired) {
            result = [self resultUnitOperationCallbackWithResponseObject:cacheObject];
            [result setDataFromCache:YES];
        } else {
            result = [self resultUnitOperationCallbackWithResponseObject:error];
        }
    } else {
        result = [self resultUnitOperationCallbackWithResponseObject:error];
    }
    NSAssert(result != nil, @"result must not be nil!");
    [result setFailureRequest:YES];
    [result setError:error];
    
    if (completeBlock) {
        completeBlock(dataTask, result);
    }
}
@end
