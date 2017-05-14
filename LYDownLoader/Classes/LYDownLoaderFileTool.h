//
//  LYDownLoaderFileTool.h
//  LYDownLoader
//
//  Created by LiuY on 2017/5/8.
//  Copyright © 2017年 DeveloperLY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYDownLoaderFileTool : NSObject

/**
 文件是否存在

 @param filePath 文件路径
 @return 是否存在
 */
+ (BOOL)isFileExists:(NSString *)filePath;


/**
 文件大小

 @param filePath 文件路径
 @return 文件大小
 */
+ (int64_t)fileSizeWithPath:(NSString *)filePath;


/**
 移动文件到另一个文件夹中

 @param fromPath 需要移动的文件
 @param toPath 目标文件位置
 */
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;


/**
 删除某个文件

 @param filePath 文件路径
 */
+ (void)removeFileAtPath:(NSString *)filePath;

@end
