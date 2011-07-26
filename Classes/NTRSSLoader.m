//
//  NTRSSLoader.m
//  NTRSSLoader
//
//  Created by Luis on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NTRSSLoader.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "GDataXMLNode.h"
#import "Config.h"

@implementation NTRSSLoader

- (id)initWithDelegate:(id<NTRSSLoaderDelegate>)aDelegate andUrl:(NSURL *)aUrl {
	self = [super init];
	if (self) {
		delegate = aDelegate;
		url = [aUrl retain];
        
        [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
	}
	
	return self;
}

- (void)refresh {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    // in case server supports 'conditional get' we avoid bringing the whole data on refresh if there is no updates
	[request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	[delegate finished:[request error]];
}

-(NSDictionary*)getItemFromXmlElement:(GDataXMLElement*)xmlItem {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[[xmlItem elementsForName:TITLE_KEY] objectAtIndex:0] stringValue] forKey:TITLE_KEY];
	[dict setObject:[[[xmlItem elementsForName:LINK_KEY] objectAtIndex:0] stringValue] forKey:LINK_KEY];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:READ_KEY];
	if ([xmlItem elementsForName:AUTHOR_KEY] != nil) {
		[dict setObject:[[[xmlItem elementsForName:AUTHOR_KEY] objectAtIndex:0] stringValue] forKey:AUTHOR_KEY];
	} else {
		[dict setObject:@"None" forKey:AUTHOR_KEY];
	}
	return dict;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if ([request didUseCachedResponse]) {
        NSLog(@"Using cached data");
#if kIncrementalItemAdd == 0
        [delegate finished:nil];
        return;
#endif
    }
    
    NSError *error = nil;
	
    GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:[request responseData] options:0 error:&error];
	
	if (doc != nil) {
		//GDataXMLNode* title = [[[doc rootElement] nodesForXPath:@"channel/title" error:&error] objectAtIndex:0];
		
		NSArray* items = [[doc rootElement] nodesForXPath:@"channel/item" error:&error];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		
		// reverse order so we generate a pseudo-publication date in order of appearance
		for (GDataXMLElement* xmlItem in [items reverseObjectEnumerator]) {			
			NSDictionary *itemDict = [self getItemFromXmlElement:xmlItem];
			
			[delegate onItem:itemDict];
		}
		
		[dateFormatter release];

		[delegate finished:nil];
	} else {
		[delegate finished:error];
	}
	
    [doc autorelease];		
}

- (void)dealloc {
	[url release];
	
	[super dealloc];
}


@end
