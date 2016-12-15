//
//  AliyunOssService.m
//  Live
//
//  Created by jacky.lee on 16/3/31.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import "AliyunOssService.h"
#import <AliyunOSSiOS/OSSService.h>
#import "UploadCGI.h"
#import "UIImage+Format.h"

@interface AliyunOssService ()
{
    OSSClient *_client;
    OSSPutObjectRequest *_putRequest;
}

@end

@implementation AliyunOssService

+ (AliyunOssService *)sharedAliyunOssService
{
    static AliyunOssService *aliyunOssService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aliyunOssService = [[AliyunOssService alloc] init];
    });
    return aliyunOssService;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self ossInit];
    }
    return self;
}


/**
 *  初始化获取OSSClient
 *  SDK自动管理Token的更新，我们只需要告诉SDK如何获取Token(比如从您的server获取)
 *  在SDK的应用中，需要实现一个回调，这个回调通过我们自己实现的方式去获取一个Federation Token(即StsToken)，然后返回。SDK会利用这个Token来进行加签处理，并在需要更新时主动调用这个回调获取Token。
 */
- (void)ossInit
{
    id <OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken *{
        return [self getFederationToken];
    }];
    _client = [[OSSClient alloc] initWithEndpoint:AliyunEndPoint credentialProvider:credential];
}

/**
 *  获取FederationToken
 */
- (OSSFederationToken *)getFederationToken
{
    OSSTaskCompletionSource *tcs = [OSSTaskCompletionSource taskCompletionSource];
    
    [UploadCGI getImageToken:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                [tcs setResult:data];
            } else {
                [tcs setResult:nil];
            }
        } else {
            [tcs setResult:nil];
        }
    }];
    
    // 实现这个回调需要同步返回Token，所以要waitUntilFinished
    [tcs.task waitUntilFinished];
    
    if (tcs.task.result) {
        NSDictionary *object = tcs.task.result;
        OSSFederationToken *token = [OSSFederationToken new];
        token.tAccessKey = object[@"accesskeyid"];
        token.tSecretKey = object[@"accesskeysecret"];
        token.tToken = object[@"securitytoken"];
        token.expirationTimeInGMTFormat = object[@"expiration"];
        return token;
    } else {
        return nil;
    }
}

/**
 *  图片预上传
 */
- (void)applyImage:(UIImage *)image complete:(void (^)(UploadPictureState state, NSString *picture))complete
{
    if (![image isKindOfClass:[UIImage class]]) {
        if (complete) {
            complete(UploadPictureState_Fail, nil);
        }
        return;
    }
    
    NSData *imgData = [image getData];
    NSString *format = [image getFormatWithData:imgData];
    if (imgData.length && format.length) {
        [UploadCGI applyImageUpload:imgData.length format:format complete:^(DGCgiResult *res) {
            if (E_OK == res._errno) {
                NSDictionary *data = res.data[@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    [self asyncPutImage:imgData data:data complete:complete];
                } else {
                    if (complete) {
                        complete(UploadPictureState_Fail, nil);
                    }
                }
            } else {
                if (complete) {
                    complete(UploadPictureState_Fail, nil);
                }
            }
        }];
    }
}

/**
 *  上传图片
 */
- (void)asyncPutImage:(NSData *)imgData
                 data:(NSDictionary *)data
             complete:(void(^)(UploadPictureState state, NSString *picture))complete
{
    _putRequest = [OSSPutObjectRequest new];
    _putRequest.bucketName = data[@"bucket"];
    _putRequest.objectKey = data[@"name"];
    _putRequest.uploadingData = imgData;
    // 上传进度回调
    _putRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        DDDLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    NSString *callbackurl = data[@"callbackurl"];
    NSString *callbackbody = data[@"callbackbody"];
    if (callbackurl.length) {
        _putRequest.callbackParam = @{
                                      @"callbackUrl": callbackurl,
                                      // callbackBody可自定义传入信息
                                      @"callbackBody": callbackbody
                                      };
    }
    
    OSSTask *task = [_client putObject:_putRequest];
    [task continueWithBlock:^id(OSSTask *task) {
        NSString *head = [NSString stringWithFormat:@"%@/%@", AliyunImage, data[@"name"]];
        if (!task.error) { // 上传成功
            DDDLog(@"上传成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(UploadPictureState_Success, head);
                }
            });
        } else { // 上传失败
            if (task.error.code == OSSClientErrorCodeTaskCancelled) {
                DDDLog(@"任务取消");
            } else {
                DDDLog(@"上传失败");
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(UploadPictureState_Fail, head);
                }
            });
        }
        _putRequest = nil;
        return nil;
    }];
}

@end
