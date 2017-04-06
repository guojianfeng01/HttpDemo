//
//  WSMultipartFormArgument.h
//  WSDataBank
//
//  Created by guojianfeng on 17/2/22.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSMultipartFormContentType){
    WSMultipartFormContentTypeNone,
    WSMultipartFormContentTypeImage,
    WSMultipartFormContentTypeZip,
    WSMultipartFormContentTypeAudio,
};

@interface WSMultipartFormArgument : NSObject
@property (nonatomic, assign) WSMultipartFormContentType contentType;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, strong) NSArray *dataValues;

+ (instancetype)instancetypeWithMultipartFormContentType:(WSMultipartFormContentType)contentType
                                                     key:(NSString *)key
                                                  values:(NSArray *)values;
@end
