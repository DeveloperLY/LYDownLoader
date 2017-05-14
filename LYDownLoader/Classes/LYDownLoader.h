//
//  LYDownLoader.h
//  LYDownLoader
//
//  Created by LiuY on 2017/5/8.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LYDownLoaderState) {
    LYDownLoaderStateUnKnown,       // 未知
    LYDownLoaderStateDowning,       // 下载中
    LYDownLoaderStatePause,         // 暂停
    LYDownLoaderStateSuccess,       // 下载成功
    LYDownLoaderStateFailed         // 下载失败
};

typedef void(^DownLoadInfoType)(int64_t totalSize);
typedef void(^ProgressBlockType)(CGFloat progress);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FailedBlockType)(NSError *error);
typedef void(^StateChangeType)(LYDownLoaderState state);

@interface NSString (MD5)

- (instancetype)md5String;

@end

@interface LYDownLoader : NSObject

/** 下载状态 */
@property (nonatomic, assign) LYDownLoaderState state;

/** 下载进度 */
@property (nonatomic, assign) CGFloat progress;

/** 下载进度Block */
@property (nonatomic, copy) ProgressBlockType downLoadProgress;

/** 下载文件信息（下载文件大小） */
@property (nonatomic, copy) DownLoadInfoType downLoadInfo;

/** 状态改变 */
@property (nonatomic, copy) StateChangeType downLoadStateChange;

/** 下载成功 */
@property (nonatomic, copy) SuccessBlockType downLoadSuccess;

/** 下载失败 */
@property (nonatomic, copy) FailedBlockType downLoadFailed;

/**
 根据URL地址下载（如果已经在下载了，继续下载，否则从头下载）

 @param url 下载地址
 */
- (void)downLoaderWithURL:(NSURL *)url;

- (void)downLoaderWithURL:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progress success:(SuccessBlockType)success failed:(FailedBlockType)failed;

/**
 暂停下载
 */
- (void)pause;


/**
 恢复下载
 */
- (void)resume;


/**
 取消当前下载(不删除缓存)
 */
- (void)cancel;


/**
 取消下载和删除缓存
 */
- (void)cancelAndClearCache;


@end
