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
@property (nonatomic, assign) int64_t tmpSize;

/** 总文件大小 */
@property (nonatomic, assign) int64_t totalSize;

/** 会话 */
@property (nonatomic, strong) NSURLSession *session;

/** 下载路径 */
@property (nonatomic, copy) NSString *tmpFilePath;

/** 下载保存路径 */
@property (nonatomic, copy) NSString *cacheFilePath;

/** 输出流 */
@property (nonatomic, strong)  NSOutputStream *outputStream;


@end

@implementation LYDownLoader

#pragma mark - Public Method
- (void)downLoaderWithURL:(NSURL *)url {
    
    self.cacheFilePath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [kTmpPath stringByAppendingPathComponent:[url.absoluteString md5String]];
    
    NSLog(@"%@", kCachePath);
    
    // 判断本地是否已经下载好
    if ([LYDownLoaderFileTool isFileExists:self.cacheFilePath]) {
        // TODO: 告诉外界已经下载完成
        NSLog(@"下载完成");
        return;
    }
    
    if (![LYDownLoaderFileTool isFileExists:self.tmpFilePath]) {
        // 从0开始请求下载资源
        [self downLoadWithURL:url bytesProgress:0];
        NSLog(@"开始下载");
        return;
    }
    
    // 读取本地缓存
    self.tmpSize = [LYDownLoaderFileTool fileSizeWithPath:self.tmpFilePath];
    [self downLoadWithURL:url bytesProgress:self.tmpSize];
}


#pragma mark - Private Method
- (void)downLoadWithURL:(NSURL *)url bytesProgress:(int64_t)bytesProgress {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", bytesProgress] forHTTPHeaderField:@"Range"];
    // NSURLSession 分配Task
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    if (self.tmpSize == self.totalSize) {
        // 移动到下载完成位置
        [LYDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        
        // 取消本次下载
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    if (self.tmpSize > self.totalSize) {
        // 删除临时数据
        [LYDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
        
        // 取消本次下载
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新下载
        [self downLoaderWithURL:response.URL];
        return;
    }
    
    // 继续接收数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 正在接收后续数据
    NSLog(@"正在接收后续数据...");
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 请求完成
    [self.outputStream close];
    self.outputStream = nil;
    
    if (!error) {
        NSLog(@"请求完成--成功！");
        [LYDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
    } else {
        NSLog(@"下载出错");
    }
    
}

#pragma mark - Setter And Getter
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

@end
