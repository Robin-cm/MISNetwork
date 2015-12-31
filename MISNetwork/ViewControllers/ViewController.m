//
//  ViewController.m
//  MISNetwork
//
//  Created by CM on 15/12/2.
//  Copyright © 2015年 changmin. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "MISWeatherApi.h"
#import "MISDownloadApi.h"

@interface ViewController () <MISRequestParamDatasource, MISRequestDelegate>

@property (nonatomic) MISDownloadApi* downloadApi;

@property (nonatomic) UIProgressView* loadingView;

@property (nonatomic) UIButton* pauseButton;

@property (nonatomic) UIActivityIndicatorView* loadingTitleView;

@property (nonatomic) NSInteger downloadRequestId;

@end

@implementation ViewController

#pragma mark - Getter

- (MISDownloadApi*)downloadApi
{
    if (!_downloadApi) {
        _downloadApi = [[MISDownloadApi alloc] init];
        _downloadApi.paramsDatasource = self;
        _downloadApi.requestDelegate = self;
    }
    return _downloadApi;
}

- (UIProgressView*)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _loadingView.frame = CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 5);
        _loadingView.trackTintColor = [UIColor blackColor];
        _loadingView.progressTintColor = [UIColor redColor];
    }
    return _loadingView;
}

- (UIButton*)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 160, 50, 30)];
        [_pauseButton setBackgroundColor:[UIColor blackColor]];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseButton addTarget:self action:@selector(pausedBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}

- (UIActivityIndicatorView*)loadingTitleView
{
    if (!_loadingTitleView) {
        _loadingTitleView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingTitleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.titleView = self.loadingTitleView;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"请求天气" style:UIBarButtonItemStylePlain target:self action:@selector(requestWeatherBtnTaped:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下载测试" style:UIBarButtonItemStylePlain target:self action:@selector(downloadBtnTaped:)];

    [self.view addSubview:self.loadingView];

    [self.view addSubview:self.pauseButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 时间

- (void)requestWeatherBtnTaped:(UIBarButtonItem*)button
{
    MISWeatherApi* weatherAPI = [[MISWeatherApi alloc] init];
    weatherAPI.shouldCache = YES;
    weatherAPI.paramsDatasource = self;
    weatherAPI.requestDelegate = self;
    [weatherAPI start];
}

- (void)downloadBtnTaped:(UIBarButtonItem*)button
{
    NSLog(@"点击了下载按钮了！！！！！！！");
    if (self.downloadApi.isLoading) {
        [self.downloadApi cancelAllRequests];
        [self.loadingTitleView stopAnimating];
        NSLog(@"停止下载！！！！！！！！");
    }
    else {
        [self.loadingTitleView startAnimating];
        self.downloadRequestId = [self.downloadApi start];
        NSLog(@"开始下载！！！！！！！！");
    }
}

- (void)pausedBtnTaped:(UIButton*)btn
{
    if ([self.downloadApi isRequestPausedWithId:self.downloadRequestId]) {
        [self.downloadApi resumeRequestWithId:self.downloadRequestId];
    }
    else {
        [self.downloadApi pauseRequestWithId:self.downloadRequestId];
    }
}

#pragma mark - MISRequestParamDatasource

- (NSDictionary*)paramsForRequest:(MISBaseRequest*)request
{
    if ([request isKindOfClass:[MISDownloadApi class]]) {
        return @{};
    }
    else if ([request isKindOfClass:[MISWeatherApi class]]) {
        return @{
            @"key" : @"e0f3392d6f54",
            @"cityname" : @"天津"
        };
    }
    else {
        return @{};
    }
}

#pragma mark - MISRequestDelegate

/**
 *  请求失败
 *
 *  @param request 请求类
 */
- (void)successWithRequest:(MISBaseRequest*)request
{
    if ([request isKindOfClass:[MISWeatherApi class]]) {
        NSLog(@"请求到的数据是 -- %@", request.responseData);
    }
    else if ([request isKindOfClass:[MISDownloadApi class]]) {
        //下载的文件
        if ([request.responseData isKindOfClass:[NSData class]]) {
            NSLog(@"请求到的数据大小是 -- %ld", ((NSData*)request.responseData).length);
            [self.loadingTitleView stopAnimating];
        }
    }
}

/**
 *  请求失败
 *
 *  @param request 请求类
 */
- (void)failWithRequest:(MISBaseRequest*)request
{
    NSLog(@"请求到的数据是 -- %@", request.responseData);
}

- (void)downloadProgressWithBytesWritten:(NSUInteger)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite request:(MISBaseRequest*)request
{
    if ([request isKindOfClass:[MISDownloadApi class]]) {
        //        NSLog(@"下载的大小是: %lld  --  总共的大小是%lld", totalBytesWritten, totalBytesExpectedToWrite);
        self.loadingView.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    }
}

@end
