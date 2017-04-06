//
//  WSResultUnit.m
//  WSDataBank
//
//  Created by guojianfeng on 17/3/21.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSResultUnit.h"
@interface WSResultUnit ()
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, assign, readwrite) id responseObject;;
@end

@implementation WSResultUnit

#pragma mark setter
- (void)setError:(NSError *)error{
    if (_error != error) {
        _error = error;
    }
}
- (void)setResponseObject:(id)responseObject{
    if (_responseObject != responseObject) {
        _responseObject = responseObject;
    }
}
- (void)setDataFromCache:(BOOL)fromCache{
    _dataFromCache = fromCache;
}
- (void)setFailureRequest:(BOOL)failureRequest{
    _failureRequest = failureRequest;
}

@end
