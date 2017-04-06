//
//  WSHttpSessionCacheUnit.h
//  WSDataBank
//
//  Created by guojianfeng on 17/3/21.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSHTTPSessionUnit.h"
#import "WSResultUnit.h"
#import "WSCacheArgument.h"

typedef void (^OperationCompleteBlock)(NSURLSessionTask *sessionTask, WSResultUnit *resultUnit);
@interface WSHttpSessionCacheUnit : WSHTTPSessionUnit
/**request*/
- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                    completeBlock:(OperationCompleteBlock)completeBlock;

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                   uploadProgress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                 downloadProgress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                    completeBlock:(OperationCompleteBlock)completeBlock;
@end
