//
//  NTErrorHandler.m
//  NTRSSReader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NTErrorHandler.h"


@implementation NTErrorHandler

// This is a good place to add logging/crash report. By now we'll just show an alert
+ (void)handleError:(NSError *)error {
	NSLog(@"error: %@", error);

	NSString *msg = [NSString stringWithFormat:@"%@. %@", [error localizedDescription], [error localizedFailureReason] ? [error localizedFailureReason] : @""];
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alertView show];
}

@end
