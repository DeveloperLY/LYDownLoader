//
//  LYDownLoadManager.m
//  LYDownLoader
//
//  Created by LiuY on 2017/5/10.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import "LYDownLoadManager.h"

@interface LYDownLoadManager () <NSCopying, NSMutableCopying>

/** 下载任务表 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, LYDownLoader *> *downLoadList;

@end

@implementation LYDownLoadManager

#pragma mark - Singleton
/// 非绝对的单例
static LYDownLoadManager *_shareInstance;
+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

#pragma mark - Public Method
- (LYDownLoader *)downLoadWithURL:(NSURL *)url {
    
    NSString *urlKey = [url.absoluteString md5String];
    
    LYDownLoader *downLoader = self.downLoadList[urlKey];
    if (downLoader) {
        [downLoader resume];
        return downLoader;
    }
    
    downLoader = [[LYDownLoader alloc] init];
    [self.downLoadList setValue:downLoader forKey:urlKey];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoaderWithURL:url downLoadInfo:nil success:^(NSString *downLoadFilePath) {
        [weakSelf.downLoadList removeObjectForKey:urlKey];
    } failed:^(NSError *error) {
        [weakSelf.downLoadList removeObjectForKey:urlKey];
    }];
    return downLoader;
}

- (void)downLoadWithURL:(NSURL *)url success:(SuccessBlockType)success failed:(FailedBlockType)failed {
    NSString *urlKey = [url.absoluteString md5String];
    
    LYDownLoader *downLoader = self.downLoadList[urlKey];
    if (downLoader) {
        [downLoader resume];
        return;
    }
    
    downLoader = [[LYDownLoader alloc] init];
    [self.downLoadList setValue:downLoader forKey:urlKey];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoaderWithURL:url downLoadInfo:nil success:^(NSString *downLoadFilePath) {
        [weakSelf.downLoadList removeObjectForKey:urlKey];
        if (success) {
            success(downLoadFilePath);
        }
    } failed:^(NSError *error) {
        [weakSelf.downLoadList removeObjectForKey:urlKey];
        if (failed) {
            failed(error);
        }
    }];
}

- (void)pauseWithURL:(NSURL *)url {
    NSString *urlKey = [url.absoluteString md5String];
    LYDownLoader *downLoader = self.downLoadList[urlKey];
    [downLoader pause];
}

- (void)resumeWithURL:(NSURL *)url {
    NSString *urlKey = [url.absoluteString md5String];
    LYDownLoader *downLoader = self.downLoadList[urlKey];
    [downLoader resume];
}

- (void)cancelWithURL:(NSURL *)url {
    NSString *urlKey = [url.absoluteString md5String];
    LYDownLoader *downLoader = self.downLoadList[urlKey];
    [downLoader cancel];
}

- (void)pauseAll {
    [[self.downLoadList allValues] makeObjectsPerformSelector:@selector(pause)];
}

- (void)resumeAll {
    [[self.downLoadList allValues] makeObjectsPerformSelector:@selector(resume)];
}

#pragma mark - Getter And Getter
- (NSMutableDictionary<NSString *,LYDownLoader *> *)downLoadList {
    if (!_downLoadList) {
        _downLoadList = [[NSMutableDictionary alloc] init];
    }
    return _downLoadList;
}

@end
