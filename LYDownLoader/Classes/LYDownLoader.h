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

@interface LYDownLoader : NSObject


/**
 根据URL地址下载（如果已经在下载了，继续下载，否则从头下载）

 @param url 下载地址
 */
- (void)downLoaderWithURL:(NSURL *)url;


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

/** 下载状态 */
@property (nonatomic, assign) LYDownLoaderState state;

@end
