//
//  LYDownLoader.m
//  LYDownLoader
//
//  Created by LiuY on 2017/5/8.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import "LYDownLoader.h"
#import "LYDownLoaderFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()

#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)

- (instancetype)md5String;

@end

@implementation NSString (MD5)

- (instancetype)md5String {
    const char *data = self.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG)strlen(data), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}

@end

@interface LYDownLoader () <NSURLSessionDataDelegate>

/** 临时文件大小 */
@property (nonatomic, assign) int64_t tmpFileSize;

/** 总文件大小 */
@property (nonatomic, assign) int64_t totalFileSize;

/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;

/** 下载路径 */
@property (nonatomic, copy) NSString *tmpFilePath;

/** 下载保存路径 */
@property (nonatomic, copy) NSString *cacheFilePath;

/** 输出流 */
@property (nonatomic, strong)  NSOutputStream *outputStream;

/** 下载任务 */
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

@end

@implementation LYDownLoader

#pragma mark - Public Method
- (void)downLoaderWithURL:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo success:(DownLoadSuccessType)success failed:(DownLoadFailType)failed {
    self.downLoadInfo = downLoadInfo;
    self.downLoadSuccess = success;
    self.downLoadFailed = failed;
    
    [self downLoaderWithURL:url];
}

- (void)downLoaderWithURL:(NSURL *)url {
    
    self.cacheFilePath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [kTmpPath stringByAppendingPathComponent:[url.absoluteString md5String]];
    
    // 判断本地是否已经下载好
    if ([LYDownLoaderFileTool isFileExists:self.cacheFilePath]) {
        // 告诉外界已经下载完成
        if (self.downLoadInfo) {
            self.downLoadInfo([LYDownLoaderFileTool fileSizeWithPath:self.cacheFilePath]);
        }
        self.state = LYDownLoaderStateSuccess;
        
        if (self.downLoadSuccess) {
            self.downLoadSuccess(self.cacheFilePath);
        }
        
        return;
    }
    
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        // 根据当前任务状态控制操作
        if (self.state == LYDownLoaderStateDowning) {
            return;
        }
        
        if (self.state == LYDownLoaderStatePause) {
            [self resume];
            return;
        }
    }
    
    // 下载地址不一样，取消当前的下载
    [self cancel];
    
    // 读取本地缓存
    self.tmpFileSize = [LYDownLoaderFileTool fileSizeWithPath:self.tmpFilePath];
    [self downLoadWithURL:url bytesProgress:self.tmpFileSize];
}

- (void)pause {
    if (self.state == LYDownLoaderStateDowning) {
        [self.dataTask suspend];
        self.state = LYDownLoaderStatePause;
    }
}

- (void)resume {
    if (self.state == LYDownLoaderStatePause) {
        [self.dataTask resume];
        self.state = LYDownLoaderStateDowning;
    }
}

- (void)cancel {
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndClearCache {
    [self cancel];
    // 删除缓存
    [LYDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
}

#pragma mark - Private Method
- (void)downLoadWithURL:(NSURL *)url bytesProgress:(int64_t)bytesProgress {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", bytesProgress] forHTTPHeaderField:@"Range"];
    // NSURLSession 分配Task
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [dataTask resume];
    self.dataTask = dataTask;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.totalFileSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalFileSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    if (self.downLoadInfo) {
        self.downLoadInfo(self.totalFileSize);
    }
    
    if (self.tmpFileSize == self.totalFileSize) {
        // 移动到下载完成位置
        [LYDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        
        self.state = LYDownLoaderStateSuccess;
        
        // 取消本次下载
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    if (self.tmpFileSize > self.totalFileSize) {
        // 删除临时数据
        [LYDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
        
        // 取消本次下载
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新下载
        [self downLoadWithURL:response.URL bytesProgress:0];
        return;
    }
    
    // 继续接收数据
    self.state = LYDownLoaderStateDowning;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 正在接收后续数据
    self.tmpFileSize += data.length;
    self.progress = 1.0 * self.tmpFileSize / self.totalFileSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 请求完成
    [self.outputStream close];
    self.outputStream = nil;
    
    if (!error) {
        [LYDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        self.state = LYDownLoaderStateSuccess;
        
        if (self.downLoadSuccess) {
            self.downLoadSuccess(self.cacheFilePath);
        }
    } else {
        self.state = LYDownLoaderStateFailed;
        
        if (self.downLoadFailed) {
            self.downLoadFailed(error);
        }
    }
    
}

#pragma mark - Setter And Getter
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)setState:(LYDownLoaderState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (self.downLoadStateChange) {
        self.downLoadStateChange(state);
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    if (self.downLoadProgress) {
        self.downLoadProgress(progress);
    }
}

@end
