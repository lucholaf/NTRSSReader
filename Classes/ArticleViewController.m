    //
//  ArticleViewController.m
//  NTRSSReader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewController.h"
#import "NTErrorHandler.h"

@implementation ArticleViewController

- (id)initWithUrl:(NSURL *)url {
	self = [super init];
	if (self) {
		url_ = [url retain];
	}
	
	return self;
}

- (void)loadView {
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;	
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:url_]];
	
	self.view = webView; // this retains it, super dealloc/viewDidUnload will release it
	
	[webView release];
	[url_ release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.navigationController)
		[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (self.navigationController)
		[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[NTErrorHandler handleError:error];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [super dealloc];
}


@end
