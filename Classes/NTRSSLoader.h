//
//  NTRSSLoader.h
//  NTRSSLoader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TITLE_KEY @"title"
#define LINK_KEY @"link"
#define AUTHOR_KEY @"author"
#define READ_KEY @"read"

@protocol NTRSSLoaderDelegate
/**
 * onItem is a reverse order callback, older items will be called first
 */
- (void)onItem:(NSDictionary *)item;

/**
 * called when all items were processed
 */
- (void)finished:(NSError *)error;
@end

@interface NTRSSLoader : NSObject {
	id<NTRSSLoaderDelegate> delegate;
	NSURL *url;
}

- (id)initWithDelegate:(id<NTRSSLoaderDelegate>)delegate andUrl:(NSURL *)url;
- (void)refresh;

@end
