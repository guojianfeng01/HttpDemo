//
//  WSMultipartFormArgument.m
//  WSDataBank
//
//  Created by guojianfeng on 17/2/22.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSMultipartFormArgument.h"
#import <UIKit/UIKit.h>

@implementation WSMultipartFormArgument

+ (instancetype)instancetypeWithMultipartFormContentType:(WSMultipartFormContentType)contentType key:(NSString *)key values:(NSArray *)values{
    WSMultipartFormArgument *formModel = [[WSMultipartFormArgument alloc]init];
    formModel.keywords = key;
    formModel.contentType = contentType;
    
    NSMutableArray *compressedArray = @[].mutableCopy;
    
    switch (contentType) {
        case WSMultipartFormContentTypeImage:{
            // 添加上传的图片
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIImage class]]){
                    // 添加上传的图片
                    CGFloat compression = 0.5f;
                    CGFloat maxCompression = 0.1f;
                    int maxFileSize = 1024*1024;
                    
                    NSData *imgData = UIImageJPEGRepresentation(obj, compression);
                    while (imgData.length > maxFileSize && compression > maxCompression){
                        compression -= 0.1;
                        imgData = UIImageJPEGRepresentation(obj, compression);
                    }
                    
                    [compressedArray addObject:imgData];
                }
            }];
        }
            break;
        case WSMultipartFormContentTypeZip:{
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSURL class]]){
                    [compressedArray addObject:obj];
                }
            }];
        }
            break;
        case WSMultipartFormContentTypeAudio:{
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSURL class]]){
                    [compressedArray addObject:obj];
                }
            }];
        }
            break;
    }
    formModel.dataValues = compressedArray;
    return formModel;
}

@end
