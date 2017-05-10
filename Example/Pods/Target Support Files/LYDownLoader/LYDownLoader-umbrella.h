#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LYDownLoader.h"
#import "LYDownLoaderFileTool.h"
#import "LYDownLoadManager.h"

FOUNDATION_EXPORT double LYDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char LYDownLoaderVersionString[];

