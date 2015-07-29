//
//  ReadingViewController.m
//  MyOne
//
//  Created by HelloWorld on 7/27/15.
//  Copyright (c) 2015 melody. All rights reserved.
//

#import "ReadingViewController.h"
#import "RightPullToRefreshView.h"
#import <unistd.h>
#import "ReadingEntity.h"
#import <MJExtension/MJExtension.h>

@interface ReadingViewController () <RightPullToRefreshViewDelegate, RightPullToRefreshViewDataSource, UIWebViewDelegate>

@property (nonatomic, strong) RightPullToRefreshView *rightPullToRefreshView;

@end

@implementation ReadingViewController {
	// 中间展示的视图控件的高度
	CGFloat refreshHeight;
	// 当前一共有多少篇文章，默认为3篇
	NSInteger numberOfItems;
	// 保存当前查看过的数据
	NSMutableArray *readItems;
	// 测试数据
	ReadingEntity *readingEntity;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setUpNavigationBarShowRightBarButtonItem:YES];
	self.view.backgroundColor = WebViewBGColor;
	
	refreshHeight = SCREEN_HEIGHT - 64 - CGRectGetHeight(self.tabBarController.tabBar.frame);
	numberOfItems = 3;
	readItems = [[NSMutableArray alloc] init];
	
	[self loadTestData];
	
	self.rightPullToRefreshView = [[RightPullToRefreshView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, refreshHeight)];
	self.rightPullToRefreshView.delegate = self;
	self.rightPullToRefreshView.dataSource = self;
	[self.view addSubview:self.rightPullToRefreshView];
	
	__weak typeof(self) weakSelf = self;
	self.hudWasHidden = ^() {
		NSLog(@"hudWasHidden");
		[weakSelf whenHUDWasHidden];
	};
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.rightPullToRefreshView.delegate = nil;
	self.rightPullToRefreshView = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - RightPullToRefreshViewDataSource

- (NSInteger)numberOfItemsInRightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView {
	NSLog(@"Person numberOfItemsInRightPullToRefreshView");
	return numberOfItems;
}

- (UIView *)rightPullToRefreshView:(RightPullToRefreshView *)rightPullToRefreshView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
	UIWebView *webView = nil;
	
	//create new view if no view is available for recycling
	if (view == nil) {
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rightPullToRefreshView.frame), CGRectGetHeight(rightPullToRefreshView.frame))];
		webView = [[UIWebView alloc] initWithFrame:view.bounds];
		webView.scrollView.showsVerticalScrollIndicator = YES;
		webView.scrollView.showsHorizontalScrollIndicator = NO;
		webView.scalesPageToFit = NO;
		webView.tag = 1;
		webView.backgroundColor = WebViewBGColor;
		webView.scrollView.backgroundColor = webView.backgroundColor;
		webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
		webView.multipleTouchEnabled = NO;
		webView.delegate = self;
//		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
//		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:readingEntity.sWebLk]]];
		
		NSMutableString *HTMLString = [[NSMutableString alloc] initWithString:readingEntity.strContent];
		NSString *insertString = [NSString stringWithFormat:@"<div style=\"margin-bottom: 185px;\"><p style=\"color: #5A5A5A; font-size: 21px; font-weight: bold; margin-top: 34px; margin-left: 5px;\">%@</p><p style=\"color: #888888; font-size: 14px; font-weight: bold; margin-left: 5px; margin-top: -15px;\">%@</p><p></p><div style=\"line-height: 26px; margin-top: 14px; margin-left: 5px; margin-right: 5px; color: #333333; font-size: 16px;\">", readingEntity.strContTitle, readingEntity.strContAuthor];
		[HTMLString insertString:insertString atIndex:0];
		NSString *appendString = [NSString stringWithFormat:@"</div><p style=\"color: #333333; font-size: 15px; font-style: oblique; margin-left: 5px;\">%@</p></div>", readingEntity.strContAuthorIntroduce];
		[HTMLString appendString:appendString];
		
		[webView loadHTMLString:HTMLString baseURL:nil];
		
		// webView 顶部添加一个 UIView，高度为34，UIView 里面再添加一个 UILabel，x 为15，y 为12，高度为16，左右距离为15，水平垂直居中，系统默认字体，颜色#555555，大小为13。
		UIView *webViewTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34)];
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(webViewTopView.frame) - 30, 16)];
		dateLabel.font = systemFont(13.0);
		dateLabel.textColor = [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1];
		// TODO : 需要转换格式
		dateLabel.text = readingEntity.strContMarketTime;
		[webViewTopView addSubview:dateLabel];
		dateLabel.center = webViewTopView.center;
		[webView.scrollView addSubview:webViewTopView];
		[view addSubview:webView];
	} else {
		webView = (UIWebView *)[view viewWithTag:1];
	}
	
	//remember to always set any properties of your carousel item
	//views outside of the `if (view == nil) {...}` check otherwise
	//you'll get weird issues with carousel item content appearing
	//in the wrong place in the carousel
	
	return view;
}

#pragma mark - RightPullToRefreshViewDelegate

- (void)rightPullToRefreshViewRefreshing:(RightPullToRefreshView *)rightPullToRefreshView {
	[self showHUDWaitingWhileExecuting:@selector(request)];
}

- (void)rightPullToRefreshViewDidScrollToLastItem:(RightPullToRefreshView *)rightPullToRefreshView {
	numberOfItems++;
	[self.rightPullToRefreshView insertItemAtIndex:(numberOfItems - 1) animated:YES];
}

#pragma mark - UIWebViewDelegate



#pragma mark - Network Requests

- (void)request {
	sleep(2);
}

#pragma mark - Private

- (void)whenHUDWasHidden {
	[self.rightPullToRefreshView endRefreshing];
}

- (void)loadTestData {
	// 先不做成可变的
	NSDictionary *testData = [BaseFunction loadTestDatasWithFileName:@"reading_content"];
	readingEntity = [ReadingEntity objectWithKeyValues:testData[@"contentEntity"]];
//	NSLog(@"readingEntity = %@", readingEntity);
}

#pragma mark - Parent

- (void)share {
	[super share];
	NSLog(@"share --------");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
