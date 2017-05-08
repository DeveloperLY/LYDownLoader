//
//  LYViewController.m
//  LYDownLoader
//
//  Created by DeveloperLY on 05/08/2017.
//  Copyright (c) 2017 DeveloperLY. All rights reserved.
//

#import "LYViewController.h"
#import "LYDownLoader/LYDownLoader.h"

@interface LYViewController ()

/** 下载工具 */
@property (nonatomic, strong) LYDownLoader *downLoader;

@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.downLoader downLoaderWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"]];
}

#pragma mark - Getter
- (LYDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[LYDownLoader alloc] init];
    }
    return _downLoader;
}

@end
