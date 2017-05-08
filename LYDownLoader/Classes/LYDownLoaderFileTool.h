//
//  LYDownLoaderFileTool.h
//  LYDownLoader
//
//  Created by LiuY on 2017/5/8.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYDownLoaderFileTool : NSObject

+ (BOOL)isFileExists:(NSString *)filePath;

+ (int64_t)fileSizeWithPath:(NSString *)filePath;

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;

+ (void)removeFileAtPath:(NSString *)filePath;

@end
