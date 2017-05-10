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

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation LYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self timer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update {
    NSLog(@"下载状态----%zd", self.downLoader.state);
}

#pragma mark - Touch/Event

- (IBAction)downLoad:(UIButton *)sender {
    [self.downLoader downLoaderWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_04.mp4"]];
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

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

@end
