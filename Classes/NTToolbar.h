//
//  NTToolbar.h
//  NTRSSReader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTToolbarDelegate

/**
 Callback for the refresh button touch
 */
- (void)activityStarted;

@end

// This is not a Toolbar UIView per se, since we will use default navigation controller's toolbar (it provides automatic rotation functionality and positioning)
// But we will use it as a separation of concerns class
@interface NTToolbar : NSObject {
	UILabel *label;
	UIView *toolbarView;
	UILabel *activityLabel;
	UIActivityIndicatorView *activity;
	
	NSString *lastUpdateTime;
	
	BOOL running;
	
	id<NTToolbarDelegate> delegate;
	
	NSDateFormatter *outputFormatter;
}

@property (readonly) BOOL running;

- (id)initWithDelegate:(id<NTToolbarDelegate>)delegate;
- (void)runWithText:(NSString *)text;
- (void)stopRunning:(BOOL)success;

// ready to use array of items for nav controller's toolbar
- (NSArray *)items;

@end
