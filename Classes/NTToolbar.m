//
//  NTToolbar.m
//  NTRSSReader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NTToolbar.h"


@implementation NTToolbar

@synthesize running;

- (id)initWithDelegate:(id<NTToolbarDelegate>)aDelegate {
	self = [super init];
	if (self != nil) {
		delegate = aDelegate;
		
		label = [[UILabel alloc] init];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = UITextAlignmentCenter;
		label.backgroundColor = [UIColor clearColor];
		
		activity = [[UIActivityIndicatorView alloc] init];		
		activity.hidesWhenStopped = YES;
		
		activityLabel = [[UILabel alloc] init];
		activityLabel.textColor = [UIColor whiteColor];
		activityLabel.textAlignment = UITextAlignmentLeft;
		activityLabel.backgroundColor = [UIColor clearColor];
		
		toolbarView = [[UIView alloc] init];
		toolbarView.backgroundColor = [UIColor clearColor];
		[toolbarView addSubview:activity];
		[toolbarView addSubview:label];		
		[toolbarView addSubview:activityLabel];
		
		int activityWidth = 20;
		int barContentHeight = 20;
		int barContentWidth = 200;
		activity.frame = CGRectMake(0, 0, activityWidth, barContentHeight);
		activityLabel.frame = CGRectMake(activityWidth + 7, 0, barContentWidth - activityWidth, barContentHeight);		
		label.frame = CGRectMake(0, 0, barContentWidth, barContentHeight);
		toolbarView.frame = CGRectMake(0, 0, barContentWidth, barContentHeight);
		
		outputFormatter = [[NSDateFormatter alloc] init];
		[outputFormatter setDateFormat:@"MM/dd/yy HH:mm"];
	}
	
	return self;
}

- (void)updateDate:(BOOL)success {
	activityLabel.alpha = 0.0;
	label.alpha = 1.0;
	
	if (success) {
		NSString *newDateString = [outputFormatter stringFromDate:[NSDate date]];		
		
		[lastUpdateTime release];
		lastUpdateTime = [[NSString stringWithFormat:@"Updated %@", newDateString] retain];
	}
	
	label.text = lastUpdateTime;
}

- (void)runWithText:(NSString *)text {
	label.alpha = 0.0;
	activityLabel.alpha = 1.0;
	activityLabel.text = text;
	
	[activity startAnimating];
	
	running = YES;
}

- (void)stopRunning:(BOOL)success {
	[activity stopAnimating];
	
	[self updateDate:success];
	
	running = NO;	
}

- (NSArray *)items {
	UIBarButtonItem *space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
	UIBarButtonItem *space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
	UIBarButtonItem *refresh = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:delegate action:@selector(activityStarted)] autorelease];
	UIBarButtonItem *titleView = [[[UIBarButtonItem alloc] initWithCustomView:toolbarView] autorelease];
	
	return [NSArray arrayWithObjects:refresh, space1, titleView, space2, nil];	
}

- (void)dealloc {
	[outputFormatter release];
	[label release];
	[activityLabel release];
	[toolbarView release];
	[activity release];
	[lastUpdateTime release];
	
	[super dealloc];
}

@end
