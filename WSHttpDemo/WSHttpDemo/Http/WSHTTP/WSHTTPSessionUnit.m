//
//  WSHTTPSessionUnit.m
//  WSDataBank
//
//  Created by guojianfeng on 17/2/22.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSHTTPSessionUnit.h"

static NSTimeInterval normalTimeoutInterval = 30;
static NSTimeInterval uploadTimeoutInterval = 60;

@interface WSHTTPSessionUnit ()
@property (nonatomic, strong) dispatch_queue_t httpRequest_queue_t;
@property (nonatomic, strong) dispatch_group_t httpRequest_group_t;
@end

@implementation WSHTTPSessionUnit
+ (instancetype)manager{
    return [[[self class] alloc] initWithBaseURL:nil];
}

- (instancetype)init {
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url sessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    return [self initWithBaseURL:nil sessionConfiguration:configuration];
}

- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self) {
        [self.requestSerializer setTimeoutInterval:normalTimeoutInterval];
        [self.reachabilityManager startMonitoring];
    }
    return self;
}

- (void)cancelTasks{
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        if (!dataTasks && !dataTasks.count) {//为何不取消updateTasks And downloadTasks
            return;
        }
        
        for (NSURLSessionTask *task in dataTasks) {
            [task cancel];
        }
    }];
}

#pragma mark - public methods

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
             successCompleteBlock:(OperationSuccessCompleteBlock) successBlock
             failureCompleteBlock:(OperationFailureCompleteBlock) failureBlock{
    return  [self request:request uploadProgress:nil downloadProgress:nil successCompleteBlock:successBlock failureCompleteBlock:failureBlock];
}

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                   uploadProgress:(void (^)(NSProgress *))uploadProgressBlock
                 downloadProgress:(void (^)(NSProgress *))downloadProgressBlock
             successCompleteBlock:(OperationSuccessCompleteBlock)successBlock
             failureCompleteBlock:(OperationFailureCompleteBlock)failureBlock{
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgressBlock
                        downloadProgress:downloadProgressBlock
                       completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                           if (error) {
                               [self operationFailureWithNSURLSessionTask:dataTask
                                                                    error:error
                                                   operationCompleteBlock:failureBlock];
                           } else {
                               [self operationSuccessWithNSURLSessionTask:dataTask responseObject:responseObject operationCompleteBlock:successBlock];
                           }
    }];
    [dataTask resume];
    return dataTask;
}

#pragma mark - JSON Request
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                      jsonParameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock{
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:[NSString stringWithFormat:@"%@", [[NSLocale preferredLanguages] componentsJoinedByString:@", "]] forHTTPHeaderField:@"Accept-Language"];
    self.requestSerializer = requestSerializer;
    NSURLSessionDataTask *dataTask = nil;
    
    dataTask = [self POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self operationSuccessWithNSURLSessionTask:task responseObject:responseObject operationCompleteBlock:successCompleteBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self operationFailureWithNSURLSessionTask:task
                                             error:error
                            operationCompleteBlock:failureCompleteBlock];
    }];
    
    return dataTask;
}

#pragma mark -  multipartForm Request
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<WSMultipartFormArgument *> *)formModels
                            progress:(void (^)(NSProgress *uploadProgress)) uploadProgress
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock{
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formModels enumerateObjectsUsingBlock:^(WSMultipartFormArgument * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WSMultipartFormArgument *formModel = obj;
            switch (formModel.contentType) {
                case WSMultipartFormContentTypeImage:{
                    [formModel.dataValues enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        NSData *imageData = obj1;
                        NSString *fileName =[NSString stringWithFormat:@"%@.jpg", formModel.keywords];
                        [formData appendPartWithFileData:imageData name:formModel.keywords fileName:fileName mimeType:@"image/jpeg"];
                    }];
                }
                    break;
                case WSMultipartFormContentTypeZip:{
                    [formModel.dataValues enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        
                        NSURL *fileURL = obj1;
                        NSString *fileName = [[fileURL pathComponents] lastObject];;
                        NSError *error = nil;
                        [formData appendPartWithFileURL:fileURL name:formModel.keywords fileName:fileName mimeType:@"application/zip" error:&error];
                    }];
                    
                }
                    break;
                case WSMultipartFormContentTypeAudio:{
                    [formModel.dataValues enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        
                        NSURL *fileURL = obj1;
                        NSString *fileName = [[fileURL pathComponents] lastObject];;
                        NSError *error = nil;
                        [formData appendPartWithFileURL:fileURL name:formModel.keywords fileName:fileName mimeType:@"audio/mpeg" error:&error];
                    }];
                }
                    break;
                default:
                    break;
            }
        }];
    } progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self operationSuccessWithNSURLSessionTask:task
                                    responseObject:responseObject
                            operationCompleteBlock:successCompleteBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self operationFailureWithNSURLSessionTask:task
                                             error:error
                            operationCompleteBlock:failureCompleteBlock];
    }];
    AFHTTPRequestSerializer *requestSerializer = self.requestSerializer;
    [requestSerializer setTimeoutInterval:uploadTimeoutInterval];
    return dataTask;
}

#pragma mark -  form Request
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock{
    return [self requestURL:URLString
                    inQueue:nil
                 HttpMethod:method
                 parameters:parameters
       successCompleteBlock:successCompleteBlock
       failureCompleteBlock:failureCompleteBlock];
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock{
    return [self requestURL:URLString inQueue:queue inGroup:nil HttpMethod:method parameters:parameters successCompleteBlock:successCompleteBlock failureCompleteBlock:failureCompleteBlock];
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock{
    
    NSURLSessionDataTask *dataTask = nil;
    if (method == HttpMethodPost){
        dataTask = [self POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self operationSuccessWithNSURLSessionTask:task
                                        responseObject:responseObject
                                operationCompleteBlock:successCompleteBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self operationFailureWithNSURLSessionTask:task
                                                 error:error
                                operationCompleteBlock:failureCompleteBlock];
        }];
    }else if (method == HttpMethodGet){
        dataTask = [self GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self operationSuccessWithNSURLSessionTask:task
                                        responseObject:responseObject
                                operationCompleteBlock:successCompleteBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self operationFailureWithNSURLSessionTask:task
                                                 error:error
                                operationCompleteBlock:failureCompleteBlock];
        }];
    }else if (method == HttpMethodDelete){
        dataTask = [self DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self operationSuccessWithNSURLSessionTask:task
                                        responseObject:responseObject
                                operationCompleteBlock:successCompleteBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self operationFailureWithNSURLSessionTask:task
                                                 error:error
                                operationCompleteBlock:failureCompleteBlock];
        }];
    }
    self.completionQueue = queue;
    self.completionGroup = group;
    return dataTask;
}

#pragma mark - private methods
//成功Block
- (void)operationSuccessWithNSURLSessionTask:(NSURLSessionTask *)dataTask
                              responseObject:(id)responseObject
                      operationCompleteBlock:(OperationSuccessCompleteBlock)completeBlock{
    if (completeBlock) {
        completeBlock(dataTask, responseObject);
    }
}

//失败Block
- (void)operationFailureWithNSURLSessionTask:(NSURLSessionTask *)dataTask
                                       error:(NSError *)error
                      operationCompleteBlock:(OperationFailureCompleteBlock)completeBlock{
    if (completeBlock) {
        completeBlock(dataTask, error);
    }
}

#pragma mark getter
- (dispatch_queue_t)httpRequest_queue_t{
    if (_httpRequest_queue_t == nil) {
        _httpRequest_queue_t = dispatch_queue_create("com.PusceneSerialQueue.DefaultHttpRequest", DISPATCH_QUEUE_SERIAL);
    }
    return _httpRequest_queue_t;
}

- (dispatch_group_t)httpRequest_group_t{
    if (!_httpRequest_group_t) {
        _httpRequest_group_t = dispatch_group_create();
    }
    return _httpRequest_group_t;
}
@end
