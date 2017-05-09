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

#pragma mark - Touch/Event

- (IBAction)downLoad:(UIButton *)sender {
    [self.downLoader downLoaderWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]];
}

- (IBAction)pause:(UIButton *)sender {
    [self.downLoader pause];
}

- (IBAction)resume:(UIButton *)sender {
    [self.downLoader resume];
}


- (IBAction)cancel:(UIButton *)sender {
    [self.downLoader cancel];
}

#pragma mark - Getter
- (LYDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[LYDownLoader alloc] init];
    }
    return _downLoader;
}

@end
