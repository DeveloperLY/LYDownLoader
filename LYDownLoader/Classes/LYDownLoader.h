//
//  LYDownLoader.h
//  LYDownLoader
//
//  Created by LiuY on 2017/5/8.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 取消当前下载
 */
- (void)cancel;

@end
