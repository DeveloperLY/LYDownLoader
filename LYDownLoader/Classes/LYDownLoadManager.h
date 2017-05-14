//
//  LYDownLoadManager.h
//  LYDownLoader
//
//  Created by LiuY on 2017/5/10.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYDownLoader.h"

@interface LYDownLoadManager : NSObject

+ (instancetype)shareInstance;

- (LYDownLoader *)downLoadWithURL:(NSURL *)url;

- (void)downLoadWithURL:(NSURL *)url success: (SuccessBlockType)success failed:(FailedBlockType)failed;

- (void)pauseWithURL:(NSURL *)url;

- (void)resumeWithURL:(NSURL *)url;

- (void)cancelWithURL:(NSURL *)url;

- (void)pauseAll;

- (void)resumeAll;

@end
