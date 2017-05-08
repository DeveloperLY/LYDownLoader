//
//  LYDownLoaderFileTool.m
//  LYDownLoader
//
//  Created by LiuY on 2017/5/8.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import "LYDownLoaderFileTool.h"

@implementation LYDownLoaderFileTool

+ (BOOL)isFileExists:(NSString *)filePath {
    if (filePath.length == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (int64_t)fileSizeWithPath:(NSString *)filePath {
    if (![self isFileExists:filePath]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath {
    if (![self isFileExists:fromPath]) {
        return;
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removeFileAtPath:(NSString *)filePath {
    if (![self isFileExists:filePath]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
