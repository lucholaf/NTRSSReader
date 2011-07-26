//
//  ArticleViewController.h
//  NTRSSReader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ArticleViewController : UIViewController<UIWebViewDelegate> {
	NSURL *url_;
}

- (id)initWithUrl:(NSURL *)url;

@end
