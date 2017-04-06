//
//  WSHTTPSessionUnit.h
//  WSDataBank
//
//  Created by guojianfeng on 17/2/22.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//
/***基于网络请求的基本封装，一个纯净的请求类，包含各种数据请求的方式***/

#import <AFNetworking/AFNetworking.h>
#import "WSMultipartFormArgument.h"

//Block
typedef void (^OperationSuccessCompleteBlock)(NSURLSessionTask *sessionTask, id responseObject);
typedef void (^OperationFailureCompleteBlock)(NSURLSessionTask *sessionTask, NSError *error);

typedef NS_ENUM(NSInteger, HttpMethod){
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodDelete,
};

@interface WSHTTPSessionUnit : AFHTTPSessionManager
#pragma mark - cancel
/**
 *  取消session中所有的请求
 */
- (void)cancelTasks;

#pragma mark - Request
- (NSURLSessionDataTask *)request:(NSURLRequest *)request
             successCompleteBlock:(OperationSuccessCompleteBlock) successBlock
             failureCompleteBlock:(OperationFailureCompleteBlock) failureBlock;

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                   uploadProgress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                 downloadProgress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
             successCompleteBlock:(OperationSuccessCompleteBlock) successBlock
             failureCompleteBlock:(OperationFailureCompleteBlock) failureBlock;

#pragma mark - JSON Request
/**
 *  JSON文本上传方法
 *
 *  @param URLString            上传API地址
 *  @param parameters           参数
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                      jsonParameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

#pragma mark -  multipartForm Request

/**
 多媒体数据文件上传

 @param URLString 上传地址
 @param parameters 表单参数构成的数组
 @param formModels 格式模型
 @param uploadProgress 上传进度回调
 @param successCompleteBlock 数据回调
 @param failureCompleteBlock 数据回调
 @return NSURLSessionDataTask
 */

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<WSMultipartFormArgument *> *)formModels
                            progress:(void (^)(NSProgress *uploadProgress)) uploadProgress
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

#pragma mark -  form Request
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;
@end
