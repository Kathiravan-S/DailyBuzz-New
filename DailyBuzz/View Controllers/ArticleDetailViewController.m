//
//  ArticleDetailViewController.m
//  DailyBuzz
//
//  Created by Kathir on 8/13/15.
//  Copyright (c) 2015 Kathir. All rights reserved.
//

#import "ArticleDetailViewController.h"

@interface ArticleDetailViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSURL *url;

@end

@implementation ArticleDetailViewController


#pragma mark -
#pragma mark View Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark -
#pragma mark Memory Management Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Private Methods

- (void)loadArticleWithUrl:(NSString *)urlString {
    if (urlString) {
        self.url = [NSURL URLWithString:urlString];
    }
}

// Load Article in WebView
- (void)loadWebView {
    if (self.url) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url];
        
        [self.webView loadRequest:urlRequest];
    }
    else {
        [self.spinner stopAnimating];
    }
}


#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.spinner stopAnimating];
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
